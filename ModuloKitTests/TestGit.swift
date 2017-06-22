//
//  TestGit.swift
//  modulo
//
//  Created by Brandon Sneed on 12/3/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
@testable import ModuloKit

class TestGit: XCTestCase {

    override func setUp() {
        super.setUp()
        moduloReset()
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGettingGitTags() {
        let status = Git().clone("git@github.com:modulo-dm/test-checkout.git", path: "test-checkout")
        XCTAssertTrue(status == .success)
        
        let tags = Git().tags("test-checkout").map {
            $0.stringValue
        }
        print(tags)
        
        Git().remove("test-checkout")
    }
    
    func testGettingBranches() {
        let status = Git().clone("git@github.com:modulo-dm/test-checkout.git", path: "test-checkout")
        XCTAssertTrue(status == .success)
        
        let branches = Git().branches("test-checkout")
        print(branches)
        
        Git().remove("test-checkout")
    }
    
    func testAddingToIgnoreFile() {
        let status = Git().clone("git@github.com:modulo-dm/test-checkout.git", path: "test-checkout")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-checkout")
        
        let localModulesPath = State.instance.modulePathName
        let pattern = "testModule"
        let textBlob = "\n# Ignore \(pattern) for Modulo.\n\(localModulesPath)/\(pattern)"
        
        let ignoreFile = "*.*\n*.DS_Store\n*.m\n*.mm" // haha, ignore all the objc's.  i kill me.
        try! ignoreFile.write(toFile: ".gitignore", atomically: true, encoding: .utf8)
        
        _ = Git().adjustIgnoreFile(pattern: pattern, removing: false)
        
        let resultingFile = try! String(contentsOfFile: ".gitignore")
        
        let found = resultingFile.contains(textBlob)
        XCTAssertTrue(found)
        
        FileManager.setWorkingPath("..")
        
        Git().remove("test-checkout")
    }

    func testRemovingFromIgnoreFile() {
        let status = Git().clone("git@github.com:modulo-dm/test-checkout.git", path: "test-checkout")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-checkout")
        
        let localModulesPath = State.instance.modulePathName
        let pattern = "testModule"
        let textBlob = "\n# Ignore \(pattern) for Modulo.\n\(localModulesPath)/\(pattern)"
        
        let ignoreFile = "*.*\n*.DS_Store\n*.m\n*.mm\n# Ignore testModule for Modulo.\nmodules/testModule"
        try! ignoreFile.write(toFile: ".gitignore", atomically: true, encoding: .utf8)
        
        _ = Git().adjustIgnoreFile(pattern: pattern, removing: true)
        
        let resultingFile = try! String(contentsOfFile: ".gitignore")
        
        let found = resultingFile.contains(textBlob)
        XCTAssertFalse(found)
        
        FileManager.setWorkingPath("..")
        
        Git().remove("test-checkout")
    }
    
}
