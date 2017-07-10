//
//  TestScenarios.swift
//  modulo
//
//  Created by Sneed, Brandon on 7/7/17.
//  Copyright © 2017 TheHolyGrail. All rights reserved.
//

import XCTest
@testable import ModuloKit

class TestScenarios: XCTestCase {
    
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
    
    func testSimeonScenario() {
        runCommand("mkdir test-simeon")
        
        FileManager.setWorkingPath("test-simeon")
        
        runCommand("git init")
        
        var result = Modulo.run(["init", "--app"])
        XCTAssertTrue(result == .success)
        
        result = Modulo.run(["add", "https://github.com/mattgallagher/CwlSignal", "--version", "2.0.0-beta.18", "-u", "-v"])
        XCTAssertTrue(result == .success)

        var tags = Git().headTagsAtPath("modules/CwlSignal")
        XCTAssertTrue(tags.contains("2.0.0-beta.18"))
        
        result = Modulo.run(["add", "https://github.com/shinydevelopment/SimulatorStatusMagic", "--version", ">=1.9.0", "-u", "-v"])
        XCTAssertTrue(result == .success)
        
        tags = Git().headTagsAtPath("modules/SimulatorStatusMagic")
        var thisVersion = Semver(tags.first!)
        var satisfies = thisVersion.satisfies(SemverRange(">=1.9.0"))
        XCTAssertTrue(satisfies)
        
        result = Modulo.run(["add", "https://github.com/realm/realm-cocoa", "--version", ">=2.8.3", "-u", "-v"])
        XCTAssertTrue(result == .success)
        
        tags = Git().headTagsAtPath("modules/realm-cocoa")
        thisVersion = Semver(tags.first!)
        satisfies = thisVersion.satisfies(SemverRange(">=2.8.3"))
        XCTAssertTrue(satisfies)
        
        // everything should be clean as a whistle right now, except the main project.
        result = Modulo.run(["status", "--ignoremain"])
        XCTAssertTrue(result == .success)
        
        runCommand("git add -A")
        testCommit("initial with modulo adds")
        
        // the main project should be clean now.
        result = Modulo.run(["status"])
        XCTAssertTrue(result == .success)
    }
    
    func testSimeonScenario2() {
        let status = Git().clone("git@github.com:modulo-dm/test-simeon.git", path: "test-simeon")
        XCTAssertTrue(status == .success)
        
        FileManager.setWorkingPath("test-simeon")
        
        var result = Modulo.run(["init", "--app"])
        XCTAssertTrue(result == .success)
        
        result = Modulo.run(["add", "https://github.com/mattgallagher/CwlSignal", "--version", "2.0.0-beta.18", "-u", "-v"])
        XCTAssertTrue(result == .success)
        
        var tags = Git().headTagsAtPath("modules/CwlSignal")
        XCTAssertTrue(tags.contains("2.0.0-beta.18"))
        
        result = Modulo.run(["add", "https://github.com/shinydevelopment/SimulatorStatusMagic", "--version", ">=1.9.0", "-u", "-v"])
        XCTAssertTrue(result == .success)
        
        tags = Git().headTagsAtPath("modules/SimulatorStatusMagic")
        var thisVersion = Semver(tags.first!)
        var satisfies = thisVersion.satisfies(SemverRange(">=1.9.0"))
        XCTAssertTrue(satisfies)
        
        result = Modulo.run(["add", "https://github.com/realm/realm-cocoa", "--version", ">=2.8.3", "-u", "-v"])
        XCTAssertTrue(result == .success)
        
        tags = Git().headTagsAtPath("modules/realm-cocoa")
        thisVersion = Semver(tags.first!)
        satisfies = thisVersion.satisfies(SemverRange(">=2.8.3"))
        XCTAssertTrue(satisfies)
        
        // everything should be clean as a whistle right now, except the main project.
        result = Modulo.run(["status", "--ignoremain"])
        XCTAssertTrue(result == .success)
        
        runCommand("git add -A")
        testCommit("initial with modulo adds")
        
        // the main project should have unpushed commits now.
        result = Modulo.run(["status"])
        XCTAssertTrue(result == .dependencyUnclean)
    }
    
}






