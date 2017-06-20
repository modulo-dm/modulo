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
    fileprivate var repositoryURL: String? = nil
    fileprivate var depName: String? = nil
    fileprivate var version: SemverRange? = nil
    fileprivate var unmanaged: Bool = false
    
    open func configureOptions() {
        addOptionValue(["--url"], usage: "sets the SCM url of the specified module", valueSignature: "<repo url>") { (option, value) -> Void in
            self.view = false
            self.repositoryURL = value
        }
        
        addOptionValue(["--version"], usage: "sets the version or range this dependency should checkout", valueSignature: "<version>") { (option, value) -> Void in
            self.view = false
            if let value = value {
                let range = SemverRange(value)
                if range.valid == true {
                    self.version = range
                    self.unmanaged = false
                }
            }
        }
        
        addOption(["--unmanaged"], usage: "sets this dependency to be unmanaged") { (option, value) in
            self.unmanaged = true
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
                if dep.unmanaged {
                    writeln(.stdout, "  name   : \(dep.name()) (unmanaged)")
                } else {
                    writeln(.stdout, "  name   : \(dep.name())")
                }
                
                writeln(.stdout, "  SCM url: \(dep.repositoryURL)")
                
                if let ver = dep.version {
                    writeln(.stdout, "  version: \(ver)\n")
                }
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

            if let ver = version {
                // TODO: this sucks.. make a method to do this.
                spec.removeDependency(dep)
                dep.version = ver
                spec.dependencies.append(dep)
                spec.save()
            } else if unmanaged {
                spec.removeDependency(dep)
                dep.version = nil
                spec.dependencies.append(dep)
                spec.save()
            }
            
            if let url = repositoryURL {
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
