//
//  ELCLITests.swift
//  ELCLITests
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Cocoa
import XCTest
import ELCLI
import ELFoundation

class ELCLITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicCommandInterpretations() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["commit", "-a", "-m", "a commit message"]
        
        // run it and see what happens
        let result: CLIResult = cli.run()!
        let command: CommitCommand = result.executedCommand as! CommitCommand
        
        // flags that match the given command line.
        XCTAssertTrue(command.all == true, "Failed.")
        XCTAssertTrue(command.message == "a commit message", "Failed.")

        // flags that aren't in use, make sure they're how they should be.
        XCTAssertTrue(command.patch == false, "Failed.")
        XCTAssertTrue(command.commit == nil, "Failed.")
    }
    
    func testBasicCommandInterpretationsWithAlternateValueMarker() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["commit", "--all", "--message=a commit message"]
        
        // run it and see what happens
        let result: CLIResult = cli.run()!
        let command: CommitCommand = result.executedCommand as! CommitCommand
        
        // flags that match the given command line.
        XCTAssertTrue(command.all == true, "Failed.")
        XCTAssertTrue(command.message == "a commit message", "Failed.")
        
        // flags that aren't in use, make sure they're how they should be.
        XCTAssertTrue(command.patch == false, "Failed.")
        XCTAssertTrue(command.commit == nil, "Failed.")
    }
    
    func testStopMarker() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["commit", "-a", "--", "-m", "a commit message"]
        
        // run it and see what happens
        let result: CLIResult = cli.run()!
        let command: CommitCommand = result.executedCommand as! CommitCommand
        
        // flags that match the given command line.
        XCTAssertTrue(command.all == true, "Failed.")
        
        // flags that aren't in use, make sure they're how they should be.
        XCTAssertTrue(command.message == nil, "Failed.")
        XCTAssertTrue(command.patch == false, "Failed.")
        XCTAssertTrue(command.commit == nil, "Failed.")
        
    }
    
    func testShowVersion() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["--version"]
        
        // run it and see what happens
        cli.run()
    }
    
    func testNoKnownCommandOrParams() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["horse", "--shit"]
        
        // run it and see what happens
        XCTAssertThrowsSpecific({ cli.run() }, THGExceptionFailure, "Failed.")
    }
    
    func testKnownCommandUnknownParams() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["commit", "--shit"]
        
        // run it and see what happens
        XCTAssertThrowsSpecific({ cli.run() }, THGExceptionFailure, "Failed.")
    }
    
    func testFlaglessOptionValues() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["commit", "-a", "-m", "a commit message", "firstFlaglessParam", "secondFlaglessParam", "thirdFlaglessParam"]
        
        // run it and see what happens
        let result: CLIResult = cli.run()!
        let command: CommitCommand = result.executedCommand as! CommitCommand
        
        // flags that match the given command line.
        XCTAssertTrue(command.all == true, "Failed.")
        XCTAssertTrue(command.message != nil, "Failed.")
        XCTAssertTrue(command.nonFlagValues.count == 3, "Failed.")
        
        XCTAssertTrue(command.nonFlagValues[0] == "firstFlaglessParam", "Failed.")
        XCTAssertTrue(command.nonFlagValues[1] == "secondFlaglessParam", "Failed.")
        XCTAssertTrue(command.nonFlagValues[2] == "thirdFlaglessParam", "Failed.")
        
        // flags that aren't in use, make sure they're how they should be.
        XCTAssertTrue(command.patch == false, "Failed.")
        XCTAssertTrue(command.commit == nil, "Failed.")
    }
    
    func testHelp() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["--help"]
        
        cli.run()
    }
    
    func testCommandHelp() {
        let cli = CLI(name: "git", version: "1.0", description: "A dummy git interface")
        
        cli.addCommands([CommitCommand()])
        
        cli.allArgumentsToExecutable = ["commit", "--help"]
        
        XCTAssertThrowsSpecific({ cli.run() }, THGExceptionFailure, "Failed.")
    }

}
