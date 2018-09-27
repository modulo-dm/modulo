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
        
        let result = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "--version", "1.0", "-v"])
        XCTAssertTrue(result == .success)
        
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
        
        let result = Modulo.run(["add", "git@github.com:modulo-dm/test-init.git", "--version", "1.0", "-v", "--update"])
        XCTAssertTrue(result == .dependencyAlreadyExists)
    }
    

    func testBasicAddModuleToModuleAndUpdate() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-add")
        
        let result = Modulo.run(["add", "git@github.com:modulo-dm/test-add-update.git", "--version", "1.0", "-v", "--update"])
        XCTAssertTrue(result == .success)
        
        let spec = ModuleSpec.load(contentsOfFile: specFilename)
        XCTAssertTrue(spec!.dependencies.count > 0)
        XCTAssertTrue(spec!.dependencies[2].repositoryURL == "git@github.com:modulo-dm/test-add-update.git")
        
        XCTAssertTrue(FileManager.fileExists("../test-add-update/README.md"))
        XCTAssertTrue(FileManager.fileExists("../test-dep1/README.md"))
        XCTAssertTrue(FileManager.fileExists("../test-dep2/README.md"))

        FileManager.setWorkingPath("..")
    }

    func testAddUnmanagedModuleWithBranch() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)

        FileManager.setWorkingPath("test-add")

        let repoURL = "git@github.com:modulo-dm/test-add-update.git"

        let result = Modulo.run(["add", repoURL, "--unmanaged", "master", "-v"])
        XCTAssertTrue(result == .success)


        guard let spec = ModuleSpec.load(contentsOfFile: specFilename) else {
            XCTFail("Failed to get spec from file \(specFilename)")
            return }
        XCTAssertTrue(spec.dependencies.count > 0)
        guard let dep = spec.dependencyForURL(repoURL) else {
            XCTFail("Failed to find dependency for url \(repoURL) in spec \(spec)")
            return }
        XCTAssertNil(dep.version)
        XCTAssertTrue(dep.unmanaged)
        XCTAssertNotNil(dep.unmanagedValue)
        XCTAssertTrue(dep.unmanagedValue == "master")

        FileManager.setWorkingPath("..")

        Git().remove("test-add")
    }

    func testAddModuleUnmanagedNoArgs() {
        let status = Git().clone("git@github.com:modulo-dm/test-add.git", path: "test-add")
        XCTAssertTrue(status == .success)

        FileManager.setWorkingPath("test-add")

        let repoURL = "git@github.com:modulo-dm/test-add-update.git"

        let result = Modulo.run(["add", repoURL, "--unmanaged", "-v"])
        XCTAssertTrue(result == .success)


        guard let spec = ModuleSpec.load(contentsOfFile: specFilename) else {
            XCTFail("Failed to get spec from file \(specFilename)")
            return }
        XCTAssertTrue(spec.dependencies.count > 0)
        guard let dep = spec.dependencyForURL(repoURL) else {
            XCTFail("Failed to find dependency for url \(repoURL) in spec \(spec)")
            return }
        XCTAssertNil(dep.version)
        XCTAssertTrue(dep.unmanaged)
        XCTAssertNil(dep.unmanagedValue)

        FileManager.setWorkingPath("..")

        Git().remove("test-add")
    }
}
