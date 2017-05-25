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
        
        let updateCommand = "git fetch --all --tags"
        let status = runCommand(updateCommand)
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .error(code: status, message: "Fetching info for '\(path)' failed.")
        }
        
        return .success
    }

    open func pull(_ path: String, remoteData: String?) -> SCMResult {
        if !FileManager.fileExists(path) {
            return .error(code: 1, message: "Module path '\(path)' does not exist.")
        }
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        var updateCommand = "git pull"
        if let remote = remoteData {
            updateCommand = updateCommand + " \(remote)"
        }
        let status = runCommand(updateCommand)
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .error(code: status, message: "Pulling updates for '\(path)' failed.")
        }
        
        return .success
    }
    
    open func checkout(_ type: SCMCheckoutType, path: String) -> SCMResult {
        if !FileManager.fileExists(path) {
            return .error(code: 1, message: "Module path '\(path)' does not exist.")
        }
        
        var checkoutCommand = ""
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        switch type {
        case .branch(let name):
            checkoutCommand = "git checkout --detach \(name)"
        case .commit(let hash):
            checkoutCommand = "git checkout \(hash)"
        case .tag(let name):
            let existingTags = tags(".")
            let range = SemverRange(name)
            if range.valid == false {
                // treat it like an exact tag, not a range
                checkoutCommand = "git checkout \(name)"
            } else if let checkoutTag = range.mostUpToDate(versions: existingTags) {
                checkoutCommand = "git checkout \(checkoutTag.stringValue)"
            } else {
                return .error(code: SCMDefaultError, message: "No tags exist, unable to checkout \(name).")
            }
        case .other(let other):
            checkoutCommand = "git checkout \(other)"
        }
        
        let status = runCommand(checkoutCommand)
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        if status != 0 {
            return .error(code: status, message: "Unable to checkout '\(type.value())'.")
        }
        
        let submodulesResult = collectAnySubmodules()
        if submodulesResult != .success {
            return submodulesResult
        }
        
        return .success
    }
    
    open func addModulesIgnore() -> SCMResult {
        let localModulesPath = State.instance.modulePathName
        
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

    open func branches(_ path: String) -> [String] {
        var result = [String]()
        
        if !FileManager.fileExists(path) {
            return result
        }
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        let command = "git branch -a"
        _ = runCommand(command) { (status, output) -> Void in
            if status == 0 {
                if let output = output {
                    let lines = output.components(separatedBy: "\n")
                    let branches = lines.map { (item) -> String in
                        var branch = item
                        branch = branch.trimmingCharacters(in: CharacterSet.whitespaces)
                        branch = branch.trimmingCharacters(in: CharacterSet(["*"," "]))
                        return branch
                    }
                    
                    result = branches
                }
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    open func remotes(_ path: String) -> [String] {
        var result = [String]()
        
        if !FileManager.fileExists(path) {
            return result
        }
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        let command = "git remote"
        _ = runCommand(command) { (status, output) -> Void in
            if status == 0 {
                if let output = output {
                    let lines = output.components(separatedBy: "\n")
                    let remotes = lines.map { (item) -> String in
                        var remote = item
                        remote = remote.trimmingCharacters(in: CharacterSet.whitespaces)
                        remote = remote.trimmingCharacters(in: CharacterSet(["*"," "]))
                        return remote
                    }
                    
                    result = remotes
                }
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }

    open func tags(_ path: String) -> [Semver] {
        var result = [Semver]()
        
        if !FileManager.fileExists(path) {
            return result
        }
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        let command = "git tag"
        _ = runCommand(command) { (status, output) -> Void in
            if status == 0 {
                if let output = output {
                    let tags = output.components(separatedBy: "\n")
                    for tag in tags {
                        result.append(Semver(tag))
                    }
                }
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    open func verifyCheckout(_ checkout: SCMCheckoutType) -> Bool {
        return false
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
    
    internal func headTagsAtPath(_ path: String) -> [String] {
        var result = [String]()
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git tag --points-at HEAD") { (status, output) in
            if let output = output {
                result = output.components(separatedBy: "\n")
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func branchAtPath(_ path: String) -> String? {
        var result = detachedBranchAtPath(path)
        if result == nil {
            result = remoteTrackingBranch(path)
        }
        return result?.trim()
    }
    
    internal func detachedBranchAtPath(_ path: String) -> String? {
        var result: String? = nil
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git branch") { (status, output) in
            if let output = output {
                let lines = output.components(separatedBy: "\n")
                for line in lines {
                    if line.contains("* (HEAD detached at") {
                        var value = line.replace("* (HEAD detached at", replacement: "")
                        value = value.replace(")", replacement: "")
                        result = value
                    }
                }
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func remoteTrackingBranch(_ path: String) -> String? {
        var result: String? = nil
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse --abbrev-ref --symbolic-full-name @{u}", silence: true) { (status, output) in
            if let output = output {
                if output.contains("fatal:") {
                    // the branch or commit doesn't exist on any remotes.
                    result = nil
                } else {
                    result = output.replacingOccurrences(of: "\n", with: "")
                }
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hashAtPath(_ path: String) -> String? {
        var result: String? = nil
        
        let initialWorkingPath = FileManager.workingPath()
        FileManager.setWorkingPath(path)
        
        _ = runCommand("git rev-parse HEAD") { (status, output) in
            if let output = output {
                result = output.replacingOccurrences(of: "\n", with: "")
            }
        }
        
        FileManager.setWorkingPath(initialWorkingPath)
        
        return result
    }
    
    internal func hashesMatch(_ hash1: String, _ hash2: String) -> Bool {
        let hashMin = min(hash1, hash2)
        let hashMax = max(hash1, hash2)
        
        return hashMax.contains(hashMin)
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
        var result = true
        
        // they're on a branch, we don't care too much, but we need to know.
        if checkout != nil {
            let initialWorkingPath = FileManager.workingPath()
            FileManager.setWorkingPath(path)
            
            if let currentHash = hashAtPath(path), let remoteBranch = remoteTrackingBranch(path) {
                let command = "git rev-list \(remoteBranch)...\(currentHash)"
                _ = runCommand(command) { (status, output) in
                    result = (output?.characters.count != 0) && (status == 0)
                }
            }
            
            FileManager.setWorkingPath(initialWorkingPath)
        }
        
        return result
    }
}





