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
        clearTestRepos()
        
        print("working path = \(NSFileManager.workingPath())")
    }
    
    override func tearDown() {
        clearTestRepos()
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicAddModuleToModule() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .Success)
        
        NSFileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "-v"])
        XCTAssertTrue(error == .Success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencyForURL("git@github.com:modulo-dm/test-add-update.git") != nil)
        //XCTAssertTrue(spec!.modulesPath == "modules")
        
        NSFileManager.setWorkingPath("..")
        
        Git().remove("test-add")
    }

    func testBasicAddModuleAlreadyExists() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .Success)
        
        let status2 = Git().clone("git@github.com:modulo-dm/test-init.git", path: "test-init")
        XCTAssertTrue(status2 == .Success)
        
        NSFileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["add", "git@github.com:modulo-dm/test-init.git", "-v", "--update"])
        XCTAssertTrue(error == .DependencyAlreadyExists)
    }
    

    func testBasicAddModuleToModuleAndUpdate() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .Success)
        
        NSFileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "-v", "--update"])
        XCTAssertTrue(error == .Success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencies[2].repositoryURL == "git@github.com:modulo-dm/test-add-update.git")
        
        XCTAssertTrue(NSFileManager.fileExists("../test-add-update/README.md"))
        XCTAssertTrue(NSFileManager.fileExists("../test-dep1/README.md"))
        XCTAssertTrue(NSFileManager.fileExists("../test-dep2/README.md"))

        NSFileManager.setWorkingPath("..")
    }
}
