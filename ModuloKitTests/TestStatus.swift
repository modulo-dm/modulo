//
//  TestStatus.swift
//  modulo
//
//  Created by Brandon Sneed on 7/18/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
@testable import ModuloKit


class TestStatus: XCTestCase {
    let modulo = Modulo()
    
    override func setUp() {
        super.setUp()
        clearTestRepos()
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        clearTestRepos()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStatusDepDirty() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        var error = Modulo.run(["update", "--all", "-v"])
        XCTAssertTrue(error == .success)
        
        touchFile("../test-dep1/blah.txt")
        
        error = Modulo.run(["status", "-v"])
        XCTAssertTrue(error == .dependencyUnclean)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-add")
    }
    
    func testStatusMainDirty() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        var error = Modulo.run(["update", "--all", "-v"])
        XCTAssertTrue(error == .success)
        
        touchFile("blah.txt")
        
        error = Modulo.run(["status", "-v"])
        XCTAssertTrue(error == .dependencyUnclean)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-add")
    }

    func testStatusMainUnpushed() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        var error = Modulo.run(["update", "--all", "-v"])
        XCTAssertTrue(error == .success)
        
        touchFile("blah.txt")
        runCommand("git add blah.txt")
        runCommand("git commit -m \"test\"")
        
        error = Modulo.run(["status", "-v"])
        XCTAssertTrue(error == .dependencyUnclean)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-add")
    }

    func testStatusDepUnpushed() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        var error = Modulo.run(["update", "--all", "-v"])
        XCTAssertTrue(error == .success)
        
        FileManager.setWorkingPath("../test-dep1")
        
        touchFile("blah.txt")
        runCommand("git add blah.txt")
        runCommand("git commit -m \"test\"")
        
        FileManager.setWorkingPath("../test-add")
        
        error = Modulo.run(["status", "-v"])
        XCTAssertTrue(error == .dependencyUnclean)
        
        FileManager.setWorkingPath("..")
        
        _ = Git().remove("test-add")
    }
    
}
