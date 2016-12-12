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
    fileprivate var checkoutType: SCMCheckoutType? = nil
    fileprivate var repositoryURL: String! = nil
    fileprivate var shouldUpdate: Bool = false
    
    // Protocol conformance
    open var name: String { return "add" }
    open var shortHelpDescription: String { return "Adds a module dependency"  }
    open var longHelpDescription: String {
        return "Add the given repository as a module to the current project and clone it " +
            "into the project itself or a higher level container project.\n\n" +
            "In the instance no tag, branch, or commit is specified, 'master' is used."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    open func configureOptions() {
        addOptionValue(["--tag"], usage: "specify the version tag to use", valueSignature: "<tag>") { (option, value) -> Void in
            if let value = value {
                var tagValue = value
                if !value.containsString("tags/") {
                    tagValue = "tags/\(value)"
                }
                self.checkoutType = .tag(name: tagValue)
            }
        }
        
        addOptionValue(["--branch"], usage: "specify the branch to use", valueSignature: "<branch>") { (option, value) -> Void in
            if let value = value {
                self.checkoutType = .branch(name: value)
            }
        }
        
        addOptionValue(["--commit"], usage: "specify the commit to use", valueSignature: "<hash>") { (option, value) -> Void in
            if let value = value {
                self.checkoutType = .commit(hash: value)
            }
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

        let result = actions.addDependency(repositoryURL, checkout: checkoutType)
        if result == .success {
            if shouldUpdate {
                writeln(.stdout, "Added \(repositoryURL).")
                if let spec = ModuleSpec.workingSpec(), let dep = spec.dependencyForURL(repositoryURL) {
                    let actions = Actions()
                    _ = actions.updateDependencies([dep], explicit: true)
                }
            } else {
                writeln(.stdout, "Added \(repositoryURL).  Run the `update` command to complete the process.")
            }
        }
        
        return result.rawValue
    }
}
