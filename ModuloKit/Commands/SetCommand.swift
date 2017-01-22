//
//  SetCommand.swift
//  modulo
//
//  Created by Sneed, Brandon on 1/21/17.
//  Copyright © 2017 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
import ELCLI
#endif

open class SetCommand: NSObject, Command {
    // Protocol conformance
    open var name: String { return "set" }
    open var shortHelpDescription: String { return "Sets dependency values"  }
    open var longHelpDescription: String {
        return "Sets dependency values, such as checkout, SCM url, etc.  When used without parameters, `set` simply prints the current values."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    // subcommands
    fileprivate var view = true
    fileprivate var checkoutType: SCMCheckoutType? = nil
    fileprivate var repositoryURL: String? = nil
    fileprivate var depName: String? = nil
    
    open func configureOptions() {
        addOptionValue(["--url"], usage: "sets the SCM url of the specified module.", valueSignature: "<repo url>") { (option, value) -> Void in
            self.view = false
            self.repositoryURL = value
        }
        
        addOptionValue(["--tag"], usage: "sets the tag this dependency should checkout", valueSignature: "<tag>") { (option, value) -> Void in
            self.view = false
            if let value = value {
                self.checkoutType = .tag(name: value)
            }
        }
        
        addOptionValue(["--branch"], usage: "sets the branch this dependency should checkout", valueSignature: "<branch>") { (option, value) -> Void in
            self.view = false
            if let value = value {
                self.checkoutType = .branch(name: value)
            }
        }
        
        addOptionValue(["--commit"], usage: "sets the commit this dependency should checkout", valueSignature: "<hash>") { (option, value) -> Void in
            self.view = false
            if let value = value {
                self.checkoutType = .commit(hash: value)
            }
        }
        
        addFlaglessOptionValues(["<dependency name>"]) { (option, value) -> Void in
            self.depName = value
        }
    }
    
    open var customUsage: String {
        return "<dependency name> [options]"
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        guard var spec = ModuleSpec.workingSpec() else {
            exit(ErrorCode.notInitialized)
            return -1
        }
        
        if view {
            writeln(.stdout, "Explicit Dependencies for `\(spec.name)`:")
            let deps = spec.dependencies
            
            for dep in deps {
                writeln(.stdout, "  name    : \(dep.name())")
                writeln(.stdout, "  SCM url : \(dep.repositoryURL)")
                writeln(.stdout, "  checkout: \(dep.checkout)\n")
            }
        } else {
            guard let depName = depName else {
                writeln(.stderr, "No module name was specified.")
                exit(ErrorCode.commandError)
                return -1
            }
            
            guard var dep = spec.dependencyForName(depName) else {
                exit(ErrorCode.dependencyUnknown)
                return -1
            }

            if let type = checkoutType {
                // TODO: this sucks.. make a method to do this.
                spec.removeDependency(dep)
                dep.checkout = type.checkoutValue()
                spec.dependencies.append(dep)
                
                spec.save()
            } else if let url = repositoryURL {
                // TODO: this sucks.. make a method to do this.
                spec.removeDependency(dep)
                dep.repositoryURL = url
                spec.dependencies.append(dep)
                
                spec.save()
            }
            
        }
            
        return 0
    }
}
