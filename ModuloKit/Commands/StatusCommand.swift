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

open class StatusCommand: NSObject, Command {
    // Protocol conformance
    open var name: String { return "status" }
    open var shortHelpDescription: String { return "Gathers status about the module tree"  }
    open var longHelpDescription: String {
        return "Gathers status about the module tree.  Uncommitted, unpushed, branch or tag mismatches, etc."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    open var ignoreMain: Bool = false
    
    open var verbose: Bool = State.instance.options.verbose
    open var quiet: Bool = false
    
    open func configureOptions() {
        addOption(["--ignoremain"], usage: "ignores the main project, scans modules only") { (option, value) in
            self.ignoreMain = true
        }

    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        let actions = Actions()
        let result = actions.checkDependenciesStatus(ignoreMain: ignoreMain)
        return result.rawValue
    }
}
