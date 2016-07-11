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

public class UpdateCommand: NSObject, Command {
    // internal properties
    private var updateAll: Bool = false
    private var dependencyName: String! = nil
    
    // Protocol conformance
    public var name: String { return "update" }
    public var shortHelpDescription: String { return "Updates module dependencies"  }
    public var longHelpDescription: String {
        return "Updates module dependencies if needed.  This command may clone sub dependencies, update the checked out versions, etc."
    }
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var verbose: Bool = false
    public var quiet: Bool = false
    
    public func configureOptions() {
        addOption(["-a", "--all"], usage: "update all dependencies") { (option, value) in
            self.updateAll = true
        }
        
        addFlaglessOptionValues(["<dependency name>"]) { (option, value) -> Void in
            self.dependencyName = value
        }
    }
    
    public func execute(otherParams: Array<String>?) -> Int {
        let actions = Actions()
        
        var deps = [DependencySpec]()
        if updateAll {
            if let workingSpec = ModuleSpec.workingSpec() {
                deps = workingSpec.dependencies
            } else {
                return ErrorCode.SpecNotFound.rawValue
            }
        } else if dependencyName != nil {
            if let dep = ModuleSpec.workingSpec()?.dependencyForName(dependencyName) {
                deps.append(dep)
            }
        } else {
            showHelp()
            return ErrorCode.CommandError.rawValue
        }
        
        if deps.count == 0 {
            return ErrorCode.NoMatchingDependencies.rawValue
        } else {
            actions.updateDependencies(deps, explicit: true)
            return ErrorCode.Success.rawValue
        }
    }
}
