//
//  AddCommand.swift
//  modulo
//
//  Created by Brandon Sneed on 6/17/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
    import ELCLI
#endif

open class AddCommand: NSObject, Command {
    // internal properties
    fileprivate var version: SemverRange? = nil
    fileprivate var repositoryURL: String! = nil
    fileprivate var shouldUpdate: Bool = false
    fileprivate var unmanaged: Bool = false
    fileprivate var unmanagedValue: String? = nil
    
    // Protocol conformance
    open var name: String { return "add" }
    open var shortHelpDescription: String { return "Adds a module dependency"  }
    open var longHelpDescription: String {
        return "Add the given repository as a module to the current project.\n\n" +
            "In unmanaged mode, it is up to the user to manage what is checked out.\n" +
            "In this case, the update command will simply do a pull.\n\n" +
            "More information on version ranges can be found at https://docs.npmjs.com/misc/semver"
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = State.instance.options.alwaysVerbose
    open var quiet: Bool = false
    
    open func configureOptions() {
        addOptionValue(["--version"], usage: "specify the version or range to use", valueSignature: "<version>") { (option, value) -> Void in
            if let value = value {
                self.version = SemverRange(value)
            }
        }
        
        addOptionValue(["--unmanaged"], usage: "specifies that this module will be unmanaged", valueSignature: "<[hash|branch|nothing]>") { (option, value) -> Void in
            self.unmanaged = true
            self.unmanagedValue = value
        }
        
        addOption(["-u", "--update"], usage: "performs the update command after adding a module") { (option, value) in
            self.shouldUpdate = true
        }
        
        addFlaglessOptionValues(["<repo url>"]) { (option, value) -> Void in
            self.repositoryURL = value
        }
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        let actions = Actions()
        
        if version == nil && unmanaged == false {
            writeln(.stderr, "A version or range must be specified via --version or --unmanaged must be used.")
            return ErrorCode.commandError.rawValue
        }
        
        if let version = version {
            if version.valid == false {
                writeln(.stderr, "The range or version specified is not valid.  Please see: https://docs.npmjs.com/misc/semver")
                return ErrorCode.commandError.rawValue
            }
        }

        let result = actions.addDependency(repositoryURL, version: version, unmanagedValue: unmanagedValue, unmanaged: unmanaged)
        if result == .success {
            if shouldUpdate {
                writeln(.stdout, "Added \(String(describing: repositoryURL)).")
                if let spec = ModuleSpec.workingSpec(), let dep = spec.dependencyForURL(repositoryURL) {
                    let actions = Actions()
                    _ = actions.updateDependencies([dep], explicit: true)
                }
            } else {
                writeln(.stdout, "Added \(String(describing: repositoryURL)).  Run the `update` command to complete the process.")
            }            
        }
        
        
        return result.rawValue
    }
}
