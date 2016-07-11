//
//  GitH.swift
//  modulo
//
//  Created by Brandon Sneed on 1/24/16.
//  Copyright © 2016 Modulo. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
    import ELFoundation
#endif

public class Git: SCM {
    public var verbose: Bool = false
    public var quiet: Bool = false
    
    public var isInstalled: Bool {
        let result = runCommand("git --version > /dev/null")
        return (result == 0)
    }
    
    public var isInitialized: Bool {
        let fileManager = NSFileManager.defaultManager()
        var isDir = ObjCBool(false)
        fileManager.fileExistsAtPath(".git", isDirectory: &isDir)
        let result = Bool(isDir)
        return result
    }
    
    public var defaultCheckout: String {
        return "master"
    }
    
    public func remoteURL() -> String? {
        var commandOutput: String? = nil
        runCommand("git config --get remote.origin.url") { (status, output) -> Void in
            if status == 0 {
                if let output = output {
                    commandOutput = output.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                }
            }
        }
        return commandOutput
    }
    
    public func nameFromRemoteURL(url: String) -> String {
        let gitURL = url
        let result = gitURL.ns.lastPathComponent.replace(".git", replacement: "")
        
        return result
    }
    
    public func clone(url: String, path: String) -> SCMResult {
        if NSFileManager.fileExists(path) {
            return .Error(message: "Module path '\(path)' already exists.")
        }
        
        let cloneCommand = "git clone \(url) \(path)"
        let status = runCommand(cloneCommand)
        
        if status != 0 {
            return .Error(message: "Clone of '\(url)' failed.")
        }
        
        return .Success
    }
    
    public func fetch(path: String) -> SCMResult {
        if !NSFileManager.fileExists(path) {
            return .Error(message: "Module path '\(path)' does not exist.")
        }
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        let updateCommand = "git fetch --tags \(path)"
        let status = runCommand(updateCommand)
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .Error(message: "Fetching info for '\(path)' failed.")
        }
        
        return .Success
    }

    public func checkout(type: SCMCheckoutType, path: String) -> SCMResult {
        if !NSFileManager.fileExists(path) {
            return .Error(message: "Module path '\(path)' does not exist.")
        }
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        var value = "master" // default to the master branch.
        switch type {
        case .Branch(let name):
            value = name
        case .Commit(let hash):
            value = hash
        case .Tag(let name):
            value = name
        case .Other(let other):
            value = other
        }
        
        let updateCommand = "git checkout \(value)"
        let status = runCommand(updateCommand)
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .Error(message: "Unable to checkout '\(value)'.")
        }
        
        let submodulesResult = collectAnySubmodules()
        if submodulesResult != .Success {
            return submodulesResult
        }
        
        return .Success
    }
    
    public func addModulesIgnore() -> SCMResult {
        // TODO: get this from the state or something and don't hardcode it.
        let localModulesPath = "modules"
        
        if NSFileManager.fileExists(".gitignore") {
            var ignoreFile = try! String(contentsOfFile: ".gitignore")
            
            // check to see if this ignore file has the exclusion already...
            if ignoreFile.containsString("\n\(localModulesPath)") {
                return .Success
            }
            
            ignoreFile += "\n# Ignore for modulo dependencies\n\(localModulesPath)\n"
            do {
                try ignoreFile.writeToFile(".gitignore", atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                return .Error(message: "Unable to write to .gitignore.  Check your permissions.")
            }
            return .Success
        } else {
            let ignoreFile = "# Add files for git to ignore\n\n# ...\n\n# Ignore for modulo dependencies\n\(localModulesPath)\n"
            do {
                try ignoreFile.writeToFile(".gitignore", atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                return .Error(message: "Unable to write to .gitignore.  Check your permissions.")
            }
            return .Success
        }
    }

    private func collectAnySubmodules() -> SCMResult {
        let updateResult = runCommand("git submodule update --init --recursive")
        if updateResult != 0 {
            return .Error(message: "Updating submodules failed.")
        }
        
        let syncResult = runCommand("git submodule sync")
        if syncResult != 0 {
            return .Error(message: "Synchronizing submodules failed.")
        }
        
        return .Success
    }
}





