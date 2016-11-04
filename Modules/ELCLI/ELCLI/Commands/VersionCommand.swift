//
//  VersionCommand.swift
//  ELCLI
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

open class VersionCommand: Command {
    fileprivate let cli: CLI
    
    open var name: String { return "--version" }
    open var shortHelpDescription: String { return "" }
    open var longHelpDescription: String { return "" }
    open var failOnUnrecognizedOptions: Bool { return false }
    
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    open func configureOptions() {
        // do nothing
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        writeln(.stdout, "\(cli.appName) version \(cli.appVersion), \(cli.appDescription)")
        
        return 0
    }
    
    init(cli: CLI) {
        self.cli = cli
    }

}
