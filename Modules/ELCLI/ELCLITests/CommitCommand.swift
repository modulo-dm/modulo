//
//  CommitCommand.swift
//  ELCLI
//
//  Created by Brandon Sneed on 8/12/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation
import ELCLI

public class CommitCommand: NSObject, Command {
    // Internal properties
    public var all: Bool = false
    public var patch: Bool = false
    public var commit: String? = nil
    public var message: String? = nil
    
    public var nonFlagValues = Array<String>()
    
    // Protocol conformance
    public var name: String { return "commit" }
    public var helpDescription: String { return "Record changes to the repository"  }
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var verbose: Bool = false
    public var quiet: Bool = false
    
    public func configureOptions() {
        addOption(["-a", "--all"], usage: "commit all changed files") { (option, value) -> Void in
            self.all = true
        }
        
        addOption(["-p", "--patch"], usage: "interactively add changes") { (option, value) -> Void in
            self.patch = true
        }
        
        addOptionValue(["-c", "-C", "--commit"], usage: "reuse message from specified commit", valueSignature: "<commit>") { (option, value) -> Void in
            self.commit = value
        }
        
        addOptionValue(["-m", "--message"], usage: "commit message", valueSignature: "<message>") { (option, value) -> Void in
            self.message = value
        }

        addFlaglessOptionValues(["<firstValue>", "<secondValue>"]) { (option, value) -> Void in
            if let value = value {
                self.nonFlagValues.append(value)
            }
        }
    }
    
    public func execute(otherParams: Array<String>?) -> CLIResult {
        var result = CLIResult()
        
        result.resultCode = 0
        result.resultDescription = "Success"
        result.executedCommand = self
        
        return result
    }
}
