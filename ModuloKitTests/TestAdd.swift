//
//  TestAdd.swift
//  modulo
//
//  Created by Brandon Sneed on 2/1/16.
//  Copyright © 2016 Modulo. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
@testable import ModuloKit


class TestAdd: XCTestCase {
    let modulo = Modulo()
    
    override func setUp() {
        super.setUp()
        moduloReset()
        
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicAddModuleToModule() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "-v"])
        XCTAssertTrue(error == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencyForURL("git@github.com:modulo-dm/test-add-update.git") != nil)
        
        FileManager.setWorkingPath("..")
        
        Git().remove("test-add")
    }

    func testBasicAddModuleAlreadyExists() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        let status2 = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status2 == .success)
        
        FileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["add", "git@github.com:modulo-dm/test-init.git", "-v", "--update"])
        XCTAssertTrue(error == .dependencyAlreadyExists)
    }
    

    func testBasicAddModuleToModuleAndUpdate() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "-v", "--update"])
        XCTAssertTrue(error == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencies[2].repositoryURL == "git@github.com:modulo-dm/test-add-update.git")
        
        XCTAssertTrue(FileManager.fileExists("../test-add-update/README.md"))
        XCTAssertTrue(FileManager.fileExists("../test-dep1/README.md"))
        XCTAssertTrue(FileManager.fileExists("../test-dep2/README.md"))

        FileManager.setWorkingPath("..")
    }
}
