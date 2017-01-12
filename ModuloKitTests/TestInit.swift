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

        moduloReset()
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNoGit() {
        cli.allArgumentsToExecutable = ["init"]
        
        xctAssertThrowsSpecific({ () -> Void in
            _ = self.cli.run()
        }, ELExceptionFailure, "It should throw because git isn't initialized.")
    }
    
    func testExplicitModuleInit() {
        let status = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-init")
        
        cli.allArgumentsToExecutable = ["init", "--module", "-v"]
        
        _ = cli.run()
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == true)
        XCTAssertTrue(spec!.dependencies.count == 0)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-init")
    }

    func testDefaultModuleInit() {
        // create a modules directory to test init inside of
        let workingPath = FileManager.workingPath()
        let modulesPath = workingPath.appendPathComponent(State.instance.modulePathName)

        do {
            try FileManager.default.createDirectory(atPath: modulesPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory at \(modulesPath), error: \(error)")
            return
        }
      
        FileManager.setWorkingPath(modulesPath)
      
        let status = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-init")
        
        cli.allArgumentsToExecutable = ["init", "-v"]
        
        _ = cli.run()
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == true)
        XCTAssertTrue(spec!.dependencies.count == 0)
        
        FileManager.setWorkingPath(workingPath)
      
        do {
            try FileManager.default.removeItem(atPath: modulesPath)
        } catch let error as NSError {
            print("Error removing directory at \(modulesPath), error: \(error)")
            return
        }

    }

  
    func testExplicitAppInit() {
        let status = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-init")
        
        cli.allArgumentsToExecutable = ["init", "--app", "-v"]
        
        _ = cli.run()
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == false)
        XCTAssertTrue(spec!.dependencies.count == 0)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-init")
    }
  
    func testDefaultAppInit() {
        let status = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-init")
        
        cli.allArgumentsToExecutable = ["init", "-v"]
        
        _ = cli.run()
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == false)
        XCTAssertTrue(spec!.dependencies.count == 0)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-init")
    }
  
    func testIsValidModuleDirectory() {
        let workingPath = FileManager.workingPath()
        let appPath = workingPath.appendPathComponent("app-directory")
        let moduleHomePath = appPath.appendPathComponent(State.instance.modulePathName)
        let testModulePath = moduleHomePath.appendPathComponent("example-module")
      
        XCTAssertTrue(InitCommand().isValidModuleDirectory(path: testModulePath))
        XCTAssertFalse(InitCommand().isValidModuleDirectory(path: appPath))
    }
    
}
