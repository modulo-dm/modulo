//
//  TestDummyApp.swift
//  modulo
//
//  Created by Sneed, Brandon on 12/12/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import XCTest
@testable import ModuloKit

class TestDummyApp: XCTestCase {
    
    override func setUp() {
        super.setUp()
        clearTestRepos()
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        clearTestRepos()
        super.tearDown()
    }
    
    func testFreshStart() {
        runCommand("mkdir test-dummy")

        FileManager.setWorkingPath("test-dummy")
        
        runCommand("git init")
        
        var error = Modulo.run(["init", "--app"])
        XCTAssertTrue(error == .success)
        
        error = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "-u", "-v"])
        XCTAssertTrue(error == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == false)
        XCTAssertTrue(spec!.name == "test-dummy")
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencyForURL("git@github.com:modulo-dm/test-add-update.git") != nil)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-add-update"))
        XCTAssertTrue(FileManager.fileExists("modules/test-dep1"))
        XCTAssertTrue(FileManager.fileExists("modules/test-dep2"))
    }
    
    func testClonedAppStart() {
        let status = Git().clone("git@github.com:modulo-dm/test-dummy.git", path: "test-dummy")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-dummy")
        
        let error = Modulo.run(["update", "--all", "-v"])
        XCTAssertTrue(error == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.module == false)
        XCTAssertTrue(spec!.name == "test-dummy")
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencyForURL("git@github.com:modulo-dm/test-add-update.git") != nil)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-add-update"))
        XCTAssertTrue(FileManager.fileExists("modules/test-dep1"))
        XCTAssertTrue(FileManager.fileExists("modules/test-dep2"))
    }
    
}
