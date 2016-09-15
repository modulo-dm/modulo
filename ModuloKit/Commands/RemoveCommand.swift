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

public class RemoveCommand: NSObject, Command {
    // Protocol conformance
    public var name: String { return "remove" }
    public var shortHelpDescription: String { return "Removes a module from the list of dependencies"  }
    public var longHelpDescription: String {
        return "Removes a module from the list of dependencies and performs checking to see if it is used elsewhere.  The filesystem is left intact for you to delete it manually at your convenience."
    }
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var verbose: Bool = false
    public var quiet: Bool = false
    
    public func configureOptions() {
        
    }
    
    public func execute(otherParams: Array<String>?) -> Int {
        let actions = Actions()
        let result = actions.checkDependenciesStatus()
        return result.rawValue
    }
}
