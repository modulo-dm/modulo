//
//  TestCheckout.swift
//  modulo
//
//  Created by Sneed, Brandon on 1/15/17.
//  Copyright © 2017 TheHolyGrail. All rights reserved.
//

import XCTest
@testable import ModuloKit

class TestCheckout: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        moduloReset()
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBranchCheckout() {
        runCommand("mkdir checkout-test")
        
        FileManager.setWorkingPath("checkout-test")
        
        runCommand("git init")
        
        var error = Modulo.run(["init", "--app"])
        XCTAssertTrue(error == .success)
        
        error = Modulo.run(["add", "git@github.com:modulo-dm/test-checkout.git", "--branch", "origin/v2-branch", "-u", "-v"])
        XCTAssertTrue(error == .success)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-checkout"))
        
        XCTAssertTrue(Git().branchAtPath("modules/test-checkout") == "v2-branch")
    }
    
    func testTagCheckout() {
        runCommand("mkdir checkout-test")
        
        FileManager.setWorkingPath("checkout-test")
        
        runCommand("git init")
        
        var error = Modulo.run(["init", "--app"])
        XCTAssertTrue(error == .success)
        
        error = Modulo.run(["add", "git@github.com:modulo-dm/test-checkout.git", "--tag", "v2.0.0", "-u", "-v"])
        XCTAssertTrue(error == .success)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-checkout"))
        
        XCTAssertTrue(Git().tagAtPath("modules/test-checkout") == "v2.0.0")
    }
    
    func testTagRangeCheckout() {
        runCommand("mkdir checkout-test")
        
        FileManager.setWorkingPath("checkout-test")
        
        runCommand("git init")
        
        var error = Modulo.run(["init", "--app"])
        XCTAssertTrue(error == .success)
        
        error = Modulo.run(["add", "git@github.com:modulo-dm/test-checkout.git", "--tag", "v2.0.0", "-u", "-v"])
        XCTAssertTrue(error == .success)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-checkout"))
        
        XCTAssertTrue(Git().tagAtPath("modules/test-checkout") == "v2.0.0")
    }

    func testCommitCheckoutShort() {
        runCommand("mkdir checkout-test")
        
        FileManager.setWorkingPath("checkout-test")
        
        runCommand("git init")
        
        var error = Modulo.run(["init", "--app"])
        XCTAssertTrue(error == .success)
        
        error = Modulo.run(["add", "git@github.com:modulo-dm/test-checkout.git", "--commit", "c4d6208", "-u", "-v"])
        XCTAssertTrue(error == .success)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-checkout"))
        
        guard let hash = Git().hashAtPath("modules/test-checkout") else { XCTFail(); return }
        XCTAssertTrue(Git().hashesMatch(hash, "c4d6208"))
    }
    
    func testCommitCheckoutLong() {
        runCommand("mkdir checkout-test")
        
        FileManager.setWorkingPath("checkout-test")
        
        runCommand("git init")
        
        var error = Modulo.run(["init", "--app"])
        XCTAssertTrue(error == .success)
        
        error = Modulo.run(["add", "git@github.com:modulo-dm/test-checkout.git", "--commit", "c4d62082ab93002e39295f6bde6659a9b68d3c59", "-u", "-v"])
        XCTAssertTrue(error == .success)
        
        XCTAssertTrue(FileManager.fileExists("modules/test-checkout"))
        
        guard let hash = Git().hashAtPath("modules/test-checkout") else { XCTFail(); return }
        XCTAssertTrue(Git().hashesMatch(hash, "c4d62082ab93002e39295f6bde6659a9b68d3c59"))
    }
    
}
