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
        return "origin/master"
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
    
    public func branchName(path: String) -> String? {
        return branchAtPath(path)
    }
    
    public func clone(url: String, path: String) -> SCMResult {
        if NSFileManager.fileExists(path) {
            return .Error(code: 1, message: "Module path '\(path)' already exists.")
        }
        
        let cloneCommand = "git clone \(url) \(path)"
        let status = runCommand(cloneCommand)
        
        if status != 0 {
            return .Error(code: status, message: "Clone of '\(url)' failed.")
        }
        
        return .Success
    }
    
    public func fetch(path: String) -> SCMResult {
        if !NSFileManager.fileExists(path) {
            return .Error(code: 1, message: "Module path '\(path)' does not exist.")
        }
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        let updateCommand = "git fetch --tags \(path)"
        let status = runCommand(updateCommand)
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .Error(code: status, message: "Fetching info for '\(path)' failed.")
        }
        
        return .Success
    }

    public func checkout(type: SCMCheckoutType, path: String) -> SCMResult {
        if !NSFileManager.fileExists(path) {
            return .Error(code: 1, message: "Module path '\(path)' does not exist.")
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
            return .Error(code: status, message: "Unable to checkout '\(value)'.")
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
                return .Error(code: 1, message: "Unable to write to .gitignore.  Check your permissions.")
            }
            return .Success
        } else {
            let ignoreFile = "# Add files for git to ignore\n\n# ...\n\n# Ignore for modulo dependencies\n\(localModulesPath)\n"
            do {
                try ignoreFile.writeToFile(".gitignore", atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                return .Error(code: 1, message: "Unable to write to .gitignore.  Check your permissions.")
            }
            return .Success
        }
    }
    
    public func checkStatus(path: String, assumedCheckout: String? = nil) -> SCMResult {
        let stashes = hasStashes(path)
        let changes = hasOutstandingChanges(path)
        let pushes = hasOutstandingPushes(assumedCheckout: assumedCheckout, path: path)
        
        var items = [String]()
        if stashes {
            items.append("stashes")
        }
        if changes {
            items.append("uncommitted changes")
        }
        if pushes {
            items.append("outstanding pushes")
        }
        
        if items.count > 0 {
            let message = items.joinWithSeparator(", ")
            return SCMResult.Error(code: Int32(ErrorCode.DependencyUnclean.rawValue), message: message)
        } else {
            return .Success
        }
    }
}

// Helper functions

extension Git {
    
    internal func collectAnySubmodules() -> SCMResult {
        let updateResult = runCommand("git submodule update --init --recursive")
        if updateResult != 0 {
            return .Error(code: 1, message: "Updating submodules failed.")
        }
        
        let syncResult = runCommand("git submodule sync")
        if syncResult != 0 {
            return .Error(code: 1, message: "Synchronizing submodules failed.")
        }
        
        return .Success
    }
    
    internal func branchAtPath(path: String) -> String? {
        // git rev-parse --abbrev-ref HEAD
        var result: String? = nil
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref HEAD") { (status, output) in
            if let output = output {
                result = output.stringByReplacingOccurrencesOfString("\n", withString: "")
            }
        }
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func remoteTrackingBranch(path: String) -> String? {
        // git rev-parse --abbrev-ref HEAD
        var result: String? = nil
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref HEAD") { (status, output) in
            if let output = output {
                result = output.stringByReplacingOccurrencesOfString("\n", withString: "")
            }
        }
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hashAtPath(path: String) -> String? {
        // git rev-parse --abbrev-ref --symbolic-full-name @{u}
        var result: String? = nil
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref --symbolic-full-name @{u}") { (status, output) in
            if let output = output {
                result = output.stringByReplacingOccurrencesOfString("\n", withString: "")
            }
        }
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hasStashes(path: String) -> Bool {
        var result = false
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        _ = runCommand("git stash list") { (status, output) in
            result = (output?.characters.count != 0) && (status == 0)
        }
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hasOutstandingChanges(path: String) -> Bool {
        var result = false
        
        let initialWorkingPath = NSFileManager.workingPath()
        NSFileManager.setWorkingPath(path)
        
        _ = runCommand("git status") { (status, output) in
            if let output = output {
                if output.rangeOfString("nothing to commit") == nil {
                    result = true
                }
            }
        }
        
        NSFileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hasOutstandingPushes(assumedCheckout checkout: String?, path: String) -> Bool {
        var result = false
        
        // they're on a branch, we don't care too much, but we need to know.
        if checkout != nil {
            let initialWorkingPath = NSFileManager.workingPath()
            NSFileManager.setWorkingPath(path)
            
            if let currentHash = hashAtPath(path), remoteBranch = remoteTrackingBranch(path) {
                _ = runCommand("git rev-list \(remoteBranch)...\(currentHash)") { (status, output) in
                    result = (output?.characters.count != 0) && (status == 0)
                }
            }
            
            NSFileManager.setWorkingPath(initialWorkingPath)
        }
        
        return result
    }
}





