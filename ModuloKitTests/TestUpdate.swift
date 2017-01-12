//
//  TestUpdate.swift
//  modulo
//
//  Created by Brandon Sneed on 6/27/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
@testable import ModuloKit


class TestUpdate: XCTestCase {
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
    
    func testUpdateAll() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["update", "--all", "-v"])
        XCTAssertTrue(error == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencies[0].repositoryURL == "git@github.com:modulo-dm/test-init.git")
        
        XCTAssertTrue(FileManager.pathExists("../test-init"))
        XCTAssertTrue(FileManager.pathExists("../test-dep1"))
        XCTAssertTrue(FileManager.pathExists("../test-dep2"))
        
        FileManager.setWorkingPath("..")
        
        Git().remove("test-add")
    }
    
    func testUpdateOneModule() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        let error = Modulo.run(["update", "-v", "test-init"])
        XCTAssertTrue(error == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencies[0].repositoryURL == "git@github.com:modulo-dm/test-init.git")
        
        XCTAssertTrue(FileManager.pathExists("../test-init"))
        
        FileManager.setWorkingPath("..")
        
        Git().remove("test-add")
    }
    
}
