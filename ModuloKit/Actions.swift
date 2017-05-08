//
//  Actions.swift
//  modulo
//
//  Created by Brandon Sneed on 6/20/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
    import ELFoundation
#endif

open class Actions {
    let scm = currentSCM()
    
    public init() {
        if !ModuleSpec.exists() {
            exit(.notInitialized)
        }
    }
    
    open func addDependency(_ url: String, checkout: SCMCheckoutType?) -> ErrorCode {
        // configure the default branch if we weren't given one.
        var checkoutType: SCMCheckoutType
        if checkout == nil {
            checkoutType = .branch(name: scm.defaultCheckout)
        } else {
            checkoutType = checkout!
        }
        
        let dep = DependencySpec(repositoryURL: url, checkout: checkoutType.checkoutValue(), redirectURL: nil)
        if var workingSpec = ModuleSpec.workingSpec() {
            // does this dep already exist in here??
            if let _ = workingSpec.dependencyForURL(url) {
                return ErrorCode.dependencyAlreadyExists
            }
            // nope, keep going.
            workingSpec.dependencies.append(dep)
            _ = workingSpec.save()
            return ErrorCode.success
        } else {
            return ErrorCode.specNotFound
        }
    }
    
    open func removeDependencies(_ dependencies: [DependencySpec]) -> ErrorCode {
        let result = ErrorCode.success
        
        return result
    }
    
    @discardableResult
    open func updateDependencies(_ dependencies: [DependencySpec], explicit: Bool) -> ErrorCode {
        let modulePath = ModuleSpec.modulePath()
        
        for dep in dependencies {
            let checkoutType = SCMCheckoutType.from(checkout: dep.checkout)
            
            // figure out what to do, where to go, what's it called, etc.
            let moduleName = scm.nameFromRemoteURL(dep.repositoryURL)
            writeln(.stdout, "working on: \(moduleName)...")
            let clonePath = modulePath.appendPathComponent(moduleName)
            
            // you might think if the path DOES exist, we'd check for version compatibility here.
            // But no... we'll do that in a seperate step.
            if FileManager.pathExists(clonePath) == false {
                // try to clone it...
                let cloneResult = scm.clone(dep.repositoryURL, path: clonePath)
                if cloneResult != .success {
                    // rrrrrrrrrrt!  STOP!  Something is jacked up.
                    exit(cloneResult.errorMessage())
                }

                // checkout what they asked for.
                let checkoutResult = scm.checkout(checkoutType, path: clonePath)
                if checkoutResult != .success {
                    exit(checkoutResult.errorMessage())
                }
                
                // things worked, so add it to the approprate place in the overall state.
                if explicit {
                    State.instance.explicitDependencies.append(dep)
                } else {
                    State.instance.implictDependencies.append(dep)
                }
            } else {
                // do a fetch ...
                let fetchResult = scm.fetch(clonePath)
                if fetchResult != .success {
                    exit(fetchResult.errorMessage())
                }
                
                // if we're on a branch do a pull
                if let pullTarget = checkoutType.branchForPull() {
                    let pullResult = scm.pull(clonePath, remoteData: pullTarget)
                    if pullResult != .success {
                        exit(pullResult.errorMessage())
                    }
                } else {
                    // it's not a branch, do a regular checkout.
                    let checkoutResult = scm.checkout(checkoutType, path: clonePath)
                    if checkoutResult != .success {
                        exit(checkoutResult.errorMessage())
                    }
                }
            }
            
            // now load the module we just worked on and iterate through it's dependencies.
            if let depSpec = ModuleSpec.load(dep) {
                let error = updateDependencies(depSpec.dependencies, explicit: false)
                if error != .success {
                    return error
                }
            }

        }
        
        return ErrorCode.success
    }
    
    open func checkDependenciesStatus() -> ErrorCode {
        var result: ErrorCode = .success
        
        writeln(.stdout, "status:")
        
        if let workingSpec = ModuleSpec.workingSpec() {
            // need to look at main dir too, not just deps.
            let mainPath = workingSpec.path.removeLastPathComponent()
            let branchName = scm.branchName(mainPath)
            let status = scm.checkStatus(mainPath, assumedCheckout: branchName)
            if status != .success {
                result = ErrorCode(rawValue: Int(status.errorCode()))!
                writeln(.stdout, "  main project has \(status.errorMessage()).")
            }
            
            // now check the deps.
            let deps = workingSpec.allDependencies()
            deps.forEach { (dependency) in
                let name = dependency.name()
                let path = ModuleSpec.modulePath().appendPathComponent(name)
                let status = scm.checkStatus(path, assumedCheckout: dependency.checkout)
                if status != .success {
                    result = ErrorCode(rawValue: Int(status.errorCode()))!
                    writeln(.stdout, "  \(name) has \(status.errorMessage()).")
                }
            }
        } else {
            result = .specNotFound
        }
        
        if result == .success {
            writeln(.stdout, "  no pending git operations or issues found.")
        }
        
        return result
    }
}













