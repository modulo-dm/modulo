//
//  SCM.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/17/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
    import ELFoundation
#endif

public typealias SCMCommandParser = (status: Int32, output: String?) -> Void

public enum SCMResult {
    case Success
    case Error(code: Int32, message: String)
    
    func errorMessage() -> String {
        switch self {
        case Error(let code, let message) :
            return "\(message), (code \(code))"
        default:
            return ""
        }
    }
    
    func errorCode() -> Int32 {
        switch self {
        case Error(let code, _) :
            return code
        default:
            return 0
        }
    }
}

extension SCMResult: Equatable {}

public func == (left: SCMResult, right: SCMResult) -> Bool {
    switch left {
    case .Success:
        switch right {
        case .Success:
            return true
        default:
            return false
        }
        
    case .Error(let leftCode, let leftMessage):
        switch right {
        case .Error(let rightCode, let rightMessage):
            return leftMessage == rightMessage && leftCode == rightCode
        default:
            return false
        }
    }
}

public enum SCMCheckoutType {
    case Branch(name: String)
    case Tag(name: String)
    case Commit(hash: String)
    case Other(value: String)
    
    func value() -> String {
        var result: String
        switch self {
        case Branch(let name):
            result = name
            break
        case Tag(let name):
            result = name
            break
        case Commit(let hash):
            result = hash
            break
        case Other(let value):
            result = value
            break
        }
        return result
    }
}


public protocol SCM {
    var verbose: Bool { get set }
    var isInstalled: Bool { get }
    var isInitialized: Bool { get }
    var defaultCheckout: String { get }
    
    func runCommand(command: String, completion: SCMCommandParser?) -> Int32
    func remoteURL() -> String?
    func nameFromRemoteURL(url: String) -> String
    func branchName(path: String) -> String?
    func clone(url: String, path: String) -> SCMResult
    func fetch(path: String) -> SCMResult
    func checkout(type: SCMCheckoutType, path: String) -> SCMResult
    func remove(path: String) -> SCMResult
    func addModulesIgnore() -> SCMResult
    func checkStatus(path: String, assumedCheckout: String?) -> SCMResult
    func tags(path: String) -> [String]
}

extension SCM {
    private func shell(command: String) -> (status: Int32, output: String?) {
        var launchPath = ""
        var pieces = command.componentsSeparatedByString(" ")
        
        switch pieces[0] {
        case "git":
            launchPath = "/usr/bin/git"
        case "rm":
            launchPath = "/bin/rm"
        default:
            return (99, nil)
        }
        
        pieces.removeFirst()
        
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = pieces
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        
        let status = task.terminationStatus
        return (status, output)
    }

    public func runCommand(command: String, completion: SCMCommandParser? = nil) -> Int32 {
        var execute = command
        
        if verbose {
            writeln(.Stdout, "Running command: \(command)")
        }
        
        let tempFile = NSFileManager.temporaryFile()
        
        if completion != nil {
            execute = "\(execute) &> \(tempFile)"
        }
        
        let result = shell(execute)//system(execute)
        
        if let completion = completion {
            let output = result.output
            let status = result.status
            completion(status: status, output: output)
            if status != 0 {
                writeln(.Stderr, output!)
            }
        }
        
        return result.status
    }
    
    public func remove(path: String) -> SCMResult {
        let result = runCommand("rm -rf \(path)")
        if result == 0 {
            return SCMResult.Success
        } else {
            return SCMResult.Error(code: result, message: "Unable to remove \(path).  Check your permissions.")
        }
    }
    
}

public func currentSCM() -> SCM {
    let scmList = [Git()/*, Mercurial()*/]
    
    var result: SCM? = nil
    for scm in scmList {
        let installed = scm.isInstalled
        let initialized = scm.isInitialized
        
        if installed && initialized {
            result = scm
            break
        }
    }
    
    if result == nil {
        exit(.NoSCMFoundOrInitialized)
    }
    
    return result!
}

