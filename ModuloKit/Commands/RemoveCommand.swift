//
//  RemoveCommand.swift
//  modulo
//
//  Created by Brandon Sneed on 7/18/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
#endif

open class RemoveCommand: NSObject, Command {
    // Protocol conformance
    open var name: String { return "remove" }
    open var shortHelpDescription: String { return "Removes a module from the list of dependencies"  }
    open var longHelpDescription: String {
        return "Removes a module from the list of dependencies and performs checking to see if it is used elsewhere.  The filesystem is left intact for you to delete it manually at your convenience."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = State.instance.options.verboseOutput
    open var quiet: Bool = false
    
    open func configureOptions() {
        
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        let actions = Actions()
        let result = actions.checkDependenciesStatus()
        return result.rawValue
    }
}
