//
//  StatusCommand.swift
//  modulo
//
//  Created by Brandon Sneed on 7/11/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
    import ELCLI
#endif

public class StatusCommand: NSObject, Command {
    // Protocol conformance
    public var name: String { return "status" }
    public var shortHelpDescription: String { return "Gathers status about the module tree"  }
    public var longHelpDescription: String {
        return "Gathers status about the module tree.  Uncommitted, unpushed, branch or tag mismatches, etc."
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
