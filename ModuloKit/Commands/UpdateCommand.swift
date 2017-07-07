//
//  UpdateCommand.swift
//  modulo
//
//  Created by Brandon Sneed on 6/21/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
    import ELCLI
#endif

open class UpdateCommand: NSObject, Command {
    // internal properties
    fileprivate var updateAll: Bool = true
    fileprivate var dependencyName: String! = nil
    fileprivate var failSilentlyIfUnused: Bool = false
    fileprivate var nonzero: Bool = false
    
    // Protocol conformance
    open var name: String { return "update" }
    open var shortHelpDescription: String { return "Updates module dependencies"  }
    open var longHelpDescription: String {
        return "Updates module dependencies if needed.  This command may clone sub dependencies, update the checked out versions, etc."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    open func configureOptions() {
        addOption(["-a", "--all"], usage: "update all dependencies (default)") { (option, value) in
            self.updateAll = true
        }
        
        addOption(["--nonzero"], usage: "return a non-zero result code if clones occurred") { (option, value) in
            self.nonzero = true
        }
        
        addOption(["--meh"], usage: "return success if modulo isn't being used or is uninitialized") { (option, value) in
            self.failSilentlyIfUnused = true
        }
        
        addFlaglessOptionValues(["<dependency name>"]) { (option, value) -> Void in
            self.dependencyName = value
            self.updateAll = false
        }
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        let actions = Actions()
        
        var deps = [DependencySpec]()
        if updateAll {
            if let workingSpec = ModuleSpec.workingSpec() {
                deps = workingSpec.dependencies
            } else {
                return ErrorCode.specNotFound.rawValue
            }
        } else if dependencyName != nil {
            if let dep = ModuleSpec.workingSpec()?.dependencyForName(dependencyName) {
                deps.append(dep)
            }
        } else {
            showHelp()
            return ErrorCode.commandError.rawValue
        }
        
        if deps.count == 0 {
            if failSilentlyIfUnused {
                return ErrorCode.success.rawValue
            } else {
                return ErrorCode.noMatchingDependencies.rawValue
            }
        } else {
            _ = actions.updateDependencies(deps, explicit: true)
            
            // if we actually cloned something, and the nonzero flag was used,
            if nonzero && State.instance.dependenciesWereCloned() {
                return 1
            }
            
            return ErrorCode.success.rawValue
        }
    }
}
