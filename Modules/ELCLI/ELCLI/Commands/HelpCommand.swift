//
//  HelpCommand.swift
//  ELCLI
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

open class HelpCommand: Command {
    fileprivate let cli: CLI
    
    open var name: String { return "--help" }
    open var shortHelpDescription: String { return "" }
    open var longHelpDescription: String { return "" }
    open var failOnUnrecognizedOptions: Bool { return false }
    
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    open func configureOptions() {
        // do nothing
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        write(.stdout, "usage: ")
        write(.stdout, "\(ProcessInfo.processInfo.processName) ")
        writeln(.stdout, "<command> [<args>]\n")

        writeln(.stdout, "The most commonly used \(cli.appName) commands are:")
        
        let commands = cli.commands
        for index in 0..<commands.count {
            printCommand(commands[index])
        }
        
        writeln(.stdout, "")
        
        return 0
    }
    
    init(cli: CLI) {
        self.cli = cli
    }
    
}
