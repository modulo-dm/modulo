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

open class Git: SCM {
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    open var isInstalled: Bool {
        let result = runCommand("git --version > /dev/null")
        return (result == 0)
    }
    
    open var isInitialized: Bool {
        let fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: ".git")
        return result
    }
    
    open var defaultCheckout: String {
        return "origin/master"
    }
    
    open func remoteURL() -> String? {
        var commandOutput: String? = nil
        _ = runCommand("git config --get remote.origin.url") { (status, output) -> Void in
            if status == 0 {
                if let output = output {
                    commandOutput = output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                }
            }
        }
        return commandOutput
    }
    
    open func nameFromRemoteURL(_ url: String) -> String {
        let gitURL = url
        let result = gitURL.ns.lastPathComponent.replace(".git", replacement: "")
        
        return result
    }
    
    open func branchName(_ path: String) -> String? {
        return branchAtPath(path)
    }
    
    open func clone(_ url: String, path: String) -> SCMResult {
        if FileManager.fileExists(path) {
            return .error(code: 1, message: "Module path '\(path)' already exists.")
        }
        
        let cloneCommand = "git clone \(url) \(path)"
        let status = runCommand(cloneCommand)
        
        if status != 0 {
            return .error(code: status, message: "Clone of '\(url)' failed.")
        }
        
        return .success
    }
    
    open func fetch(_ path: String) -> SCMResult {
        if !FileManager.fileExists(path) {
            return .error(code: 1, message: "Module path '\(path)' does not exist.")
        }
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        let updateCommand = "git fetch --tags \(path)"
        let status = runCommand(updateCommand)
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .error(code: status, message: "Fetching info for '\(path)' failed.")
        }
        
        return .success
    }

    open func checkout(_ type: SCMCheckoutType, path: String) -> SCMResult {
        if !FileManager.fileExists(path) {
            return .error(code: 1, message: "Module path '\(path)' does not exist.")
        }
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        var value = "master" // default to the master branch.
        switch type {
        case .branch(let name):
            value = name
        case .commit(let hash):
            value = hash
        case .tag(let name):
            value = name
        case .other(let other):
            value = other
        }
        
        let updateCommand = "git checkout \(value)"
        let status = runCommand(updateCommand)
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .error(code: status, message: "Unable to checkout '\(value)'.")
        }
        
        let submodulesResult = collectAnySubmodules()
        if submodulesResult != .success {
            return submodulesResult
        }
        
        return .success
    }
    
    open func addModulesIgnore() -> SCMResult {
        // TODO: get this from the state or something and don't hardcode it.
        let localModulesPath = "modules"
        
        if FileManager.fileExists(".gitignore") {
            var ignoreFile = try! String(contentsOfFile: ".gitignore")
            
            // check to see if this ignore file has the exclusion already...
            if ignoreFile.containsString("\n\(localModulesPath)") {
                return .success
            }
            
            ignoreFile += "\n# Ignore for modulo dependencies\n\(localModulesPath)\n"
            do {
                try ignoreFile.write(toFile: ".gitignore", atomically: true, encoding: String.Encoding.utf8)
            } catch {
                return .error(code: 1, message: "Unable to write to .gitignore.  Check your permissions.")
            }
            return .success
        } else {
            let ignoreFile = "# Add files for git to ignore\n\n# ...\n\n# Ignore for modulo dependencies\n\(localModulesPath)\n"
            do {
                try ignoreFile.write(toFile: ".gitignore", atomically: true, encoding: String.Encoding.utf8)
            } catch {
                return .error(code: 1, message: "Unable to write to .gitignore.  Check your permissions.")
            }
            return .success
        }
    }
    
    open func checkStatus(_ path: String, assumedCheckout: String? = nil) -> SCMResult {
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
            let message = items.joined(separator: ", ")
            return SCMResult.error(code: Int32(ErrorCode.dependencyUnclean.rawValue), message: message)
        } else {
            return .success
        }
    }
    
    open func tags(_ path: String) -> [String] {
        // TODO: this.. duh.
        return [""]
    }
}

// Helper functions

extension Git {
    
    internal func collectAnySubmodules() -> SCMResult {
        let updateResult = runCommand("git submodule update --init --recursive")
        if updateResult != 0 {
            return .error(code: 1, message: "Updating submodules failed.")
        }
        
        let syncResult = runCommand("git submodule sync")
        if syncResult != 0 {
            return .error(code: 1, message: "Synchronizing submodules failed.")
        }
        
        return .success
    }
    
    internal func branchAtPath(_ path: String) -> String? {
        // git rev-parse --abbrev-ref HEAD
        var result: String? = nil
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref HEAD") { (status, output) in
            if let output = output {
                result = output.replacingOccurrences(of: "\n", with: "")
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func remoteTrackingBranch(_ path: String) -> String? {
        // git rev-parse --abbrev-ref HEAD
        var result: String? = nil
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref HEAD") { (status, output) in
            if let output = output {
                result = output.replacingOccurrences(of: "\n", with: "")
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hashAtPath(_ path: String) -> String? {
        // git rev-parse --abbrev-ref --symbolic-full-name @{u}
        var result: String? = nil
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref --symbolic-full-name @{u}") { (status, output) in
            if let output = output {
                result = output.replacingOccurrences(of: "\n", with: "")
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hasStashes(_ path: String) -> Bool {
        var result = false
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git stash list") { (status, output) in
            result = (output?.characters.count != 0) && (status == 0)
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hasOutstandingChanges(_ path: String) -> Bool {
        var result = false
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git status") { (status, output) in
            if let output = output {
                if output.range(of: "nothing to commit") == nil {
                    result = true
                }
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hasOutstandingPushes(assumedCheckout checkout: String?, path: String) -> Bool {
        var result = false
        
        // they're on a branch, we don't care too much, but we need to know.
        if checkout != nil {
            let initialWorkingPath = FileManager.workingPath()
            FileManager.setWorkingPath(path)
            
            if let currentHash = hashAtPath(path), let remoteBranch = remoteTrackingBranch(path) {
                _ = runCommand("git rev-list \(remoteBranch)...\(currentHash)") { (status, output) in
                    result = (output?.characters.count != 0) && (status == 0)
                }
            }
            
            FileManager.setWorkingPath(initialWorkingPath)
        }
        
        return result
    }
}





