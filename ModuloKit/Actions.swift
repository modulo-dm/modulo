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

public typealias DependencyClosure = (dependency: DependencySpec) -> ErrorCode

public class Actions {
    let scm = currentSCM()
    
    public init() {
        if !ModuleSpec.exists() {
            exit(.NotInitialized)
        }
    }
    
    public func recurse(dependencies: [DependencySpec], apply: DependencyClosure) {
        for dep in dependencies {
            apply(dependency: dep)
            recurse([dep], apply: apply)
        }
    }
    
    public func addDependency(url: String, checkout: SCMCheckoutType?) -> ErrorCode {
        // configure the default branch if we weren't given one.
        var checkoutType: SCMCheckoutType
        if checkout == nil {
            checkoutType = .Branch(name: scm.defaultCheckout)
        } else {
            checkoutType = checkout!
        }
        
        let dep = DependencySpec(repositoryURL: url, checkout: checkoutType.value(), redirectURL: nil)
        if var workingSpec = ModuleSpec.workingSpec() {
            // does this dep already exist in here??
            if let _ = workingSpec.dependencyForURL(url) {
                return ErrorCode.DependencyAlreadyExists
            }
            // nope, keep going.
            workingSpec.dependencies.append(dep)
            workingSpec.save()
            return ErrorCode.Success
        } else {
            return ErrorCode.SpecNotFound
        }
    }
    
    public func updateDependencies(dependencies: [DependencySpec], explicit: Bool) -> ErrorCode {
        let modulePath = ModuleSpec.modulePath()
        
        for dep in dependencies {
            // figure out what to do, where to go, what's it called, etc.
            let moduleName = scm.nameFromRemoteURL(dep.repositoryURL)
            writeln(.Stdout, "working on: \(moduleName)...")
            let clonePath = modulePath.appendPathComponent(moduleName)
            
            // you might think if the path DOES exist, we'd check for version compatibility here.
            // But no... we'll do that in a seperate step.
            if NSFileManager.pathExists(clonePath) == false {
                // try to clone it...
                let cloneResult = scm.clone(dep.repositoryURL, path: clonePath)
                if cloneResult != .Success {
                    // rrrrrrrrrrt!  STOP!  Something is jacked up.
                    exit(cloneResult.errorMessage())
                }
                
                // now check out what they asked for...
                let checkoutType = SCMCheckoutType.Other(value: dep.checkout)
                let checkoutResult = scm.checkout(checkoutType, path: clonePath)
                
                if checkoutResult != .Success {
                    // rrrrrrrrrrt!  STOP!  Something is jacked up.
                    exit(checkoutResult.errorMessage())
                }
                
                // things worked, so add it to the approprate place in the overall state.
                if explicit {
                    State.instance.explicitDependencies.append(dep)
                } else {
                    State.instance.implictDependencies.append(dep)
                }
            }
            
            // now load the module we just worked on and iterate through it's dependencies.
            if let depSpec = ModuleSpec.load(dep) {
                let error = updateDependencies(depSpec.dependencies, explicit: false)
                if error != .Success {
                    return error
                }
            }

        }
        
        return ErrorCode.Success
    }
}













