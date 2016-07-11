//
//  TestInit.swift
//  modulo
//
//  Created by Brandon Sneed on 2/1/16.
//  Copyright © 2016 Modulo. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
@testable import ModuloKit

class TestInit: XCTestCase {
    let cli: CLI = CLI(name: "modulo", version: "1.0", description: "A dummy interface")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cli.addCommands([InitCommand()])

        clearTestRepos()
        print("working path = \(NSFileManager.workingPath())")
    }
    
    override func tearDown() {
        clearTestRepos()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNoGit() {
        cli.allArgumentsToExecutable = ["init"]
        
        XCTAssertThrowsSpecific({ () -> Void in
            self.cli.run()
        }, ELExceptionFailure, "It should throw because git isn't initialized.")
    }
    
    func testModuleInit() {
        let status = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status == .Success)
        
        NSFileManager.setWorkingPath("test-init")
        
        cli.allArgumentsToExecutable = ["init", "-v"]
        
        cli.run()
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == true)
        XCTAssertTrue(spec!.dependencies.count == 0)
        
        NSFileManager.setWorkingPath("..")
        
        Git().remove("test-init")
    }
    
    func testAppInit() {
        let status = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status == .Success)
        
        NSFileManager.setWorkingPath("test-init")
        
        cli.allArgumentsToExecutable = ["init", "--app", "-v"]
        
        cli.run()
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == false)
        XCTAssertTrue(spec!.dependencies.count == 0)
        
        NSFileManager.setWorkingPath("..")
        
        Git().remove("test-init")
    }
    
}
