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

}
