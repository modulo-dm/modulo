//
//  SemverTests.swift
//  modulo
//
//  Created by Brandon Sneed on 8/9/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import XCTest
@testable import ModuloKit

class SemverTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXRangeCreation() {
        var semver = Semver("1.x")
        XCTAssertTrue(semver.breaking == 1)
        XCTAssertTrue(semver.partial)
        
        semver = Semver("1.2.*")
        XCTAssertTrue(semver.breaking == 1 && semver.feature == 2)
        XCTAssertTrue(semver.partial)
    }

    func testSomeVersionStrings() {
        var semver = Semver("  =v1.2.3   ")
        
        XCTAssertTrue(semver.valid)
        XCTAssertTrue(semver.breaking == 1 && semver.feature == 2 && semver.fix == 3)

        semver = Semver("a.b.c")
        
        XCTAssertFalse(semver.valid)
        
        semver = Semver("1.0.0-alpha+001")
        
        XCTAssertTrue(semver.breaking == 1)
        XCTAssertTrue(semver.preRelease == "alpha")
        XCTAssertTrue(semver.build == "001")
        
        semver = Semver("=v1.2.3-alpha.0.1.22+abcdef.1.2")
        
        XCTAssertTrue(semver.breaking == 1 && semver.feature == 2 && semver.fix == 3)
        XCTAssertTrue(semver.preRelease == "alpha")
        XCTAssertTrue(semver.preReleaseVersionData[0] == 0)
        XCTAssertTrue(semver.preReleaseVersionData[1] == 1)
        XCTAssertTrue(semver.preReleaseVersionData[2] == 22)
        XCTAssertTrue(semver.build == "abcdef.1.2")
        
        semver = Semver("1.2.x")
        XCTAssertTrue(semver.valid == true)
    }

    func testEqualityOperators() {
        var semver1 = Semver("1.2.3-0.1.3")
        var semver2 = Semver("0.3.3-0.1.3")
        
        XCTAssertFalse(semver1 == semver2)
        XCTAssertTrue(semver1 > semver2)
        XCTAssertTrue(semver1 >= semver2)
        XCTAssertFalse(semver1 < semver2)
        XCTAssertFalse(semver1 <= semver2)

        semver1 = Semver("1.2.3-0.1.3")
        semver2 = Semver("1.2.3-0.1.3")
        
        XCTAssertTrue(semver1 == semver2)
        XCTAssertFalse(semver1 > semver2)
        XCTAssertTrue(semver1 >= semver2)
        XCTAssertFalse(semver1 < semver2)
        XCTAssertTrue(semver1 <= semver2)
        
        semver1 = Semver("1.11.0")
        semver2 = Semver("1.1.1-0")
        
        XCTAssertTrue(semver1 > semver2)
        XCTAssertFalse(semver1 < semver2)
        
        semver1 = Semver("1.11.0")
        semver2 = Semver("1.1.1.0")
        
        XCTAssertTrue(semver1 > semver2)
        XCTAssertFalse(semver1 < semver2)
    }
    
    func testJunkUpFront() {
        var semver = Semver("node-v3.3.3-pre.1")

        XCTAssertTrue(semver.valid == true)
        XCTAssertTrue(semver.prefix == "node-v")
        
        semver = Semver("node-v3.3.3-pre.1+build3")
        
        XCTAssertTrue(semver.valid == true)
        XCTAssertTrue(semver.prefix == "node-v")
        XCTAssertTrue(semver.build == "build3")
        
        semver = Semver("node-v3.3.3-pre.1+build.3")
        
        XCTAssertTrue(semver.valid == true)
        XCTAssertTrue(semver.prefix == "node-v")
        XCTAssertTrue(semver.build == "build.3")
    }
    
    func testRangeParsing() {
        var range = SemverRange("1.x || >=2.5.0 || 5.0.0 -  7.2.3")
        print(range.comparators)
        
        XCTAssertTrue(range.comparators[0].description == ">=1.0.0")
        XCTAssertTrue(range.comparators[1].description == "<2.0.0")
        XCTAssertTrue(range.comparators[2].description == "||")
        XCTAssertTrue(range.comparators[3].description == ">=2.5.0")
        XCTAssertTrue(range.comparators[4].description == "||")
        XCTAssertTrue(range.comparators[5].description == ">=5.0.0")
        XCTAssertTrue(range.comparators[6].description == "<=7.2.3")
        XCTAssertTrue(range.comparators[7].description == "||")

        range = SemverRange("~0")
        print(range.comparators)
        
        XCTAssertTrue(range.comparators[0].description == ">=0.0.0")
        XCTAssertTrue(range.comparators[1].description == "<1.0.0")
        
        range = SemverRange("^0")
        print(range.comparators)
        
        XCTAssertTrue(range.comparators[0].description == ">=0.0.0")
        XCTAssertTrue(range.comparators[1].description == "<0.1.0")
        
        range = SemverRange("^1.2.3")
        print(range.comparators)
        
        XCTAssertTrue(range.comparators[0].description == ">=1.2.3")
        XCTAssertTrue(range.comparators[1].description == "<2.0.0")
        
        range = SemverRange("~1.2.3-beta.2")
        print(range.comparators)
        
        XCTAssertTrue(range.comparators[0].description == ">=1.2.3-beta.2")
        XCTAssertTrue(range.comparators[1].description == "<1.3.0")
    }
    
    func testNonPreReleaseRangeSatisfaction() {
        let range = SemverRange("5.0.0 - 7.2.3")
        
        var ver = Semver("7.2.1")
        XCTAssertTrue(ver.satisfies(range))
        
        ver = Semver("7.2.1-rc.1")
        XCTAssertFalse(ver.satisfies(range))
    }
    
    func testPreReleaseRangeSatisfaction() {
        var range = SemverRange("5.0.0 - 7.2.1-rc.2")
        
        var ver = Semver("7.2.1-rc.1")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("7.2.0")
        XCTAssertTrue(ver.satisfies(range))
        
        ver = Semver("7.2.0-rc.1")
        XCTAssertFalse(ver.satisfies(range))
        ver = Semver("7.2.1-pre.1")
        XCTAssertFalse(ver.satisfies(range))
        
        range = SemverRange("~1.2.3-beta.2")
        
        ver = Semver("1.2.3-beta.3")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("1.2.9")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("1.2.4-beta.2")
        XCTAssertFalse(ver.satisfies(range))
        ver = Semver("1.3.0")
        XCTAssertFalse(ver.satisfies(range))

        range = SemverRange("^1.2.3-beta.2")
        
        ver = Semver("1.2.3-beta.3")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("1.2.9")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("1.2.4-beta.2")
        XCTAssertFalse(ver.satisfies(range))
        ver = Semver("1.3.0")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("2.0.0")
        XCTAssertFalse(ver.satisfies(range))
    }
    
    func testBasicSatisfaction() {
        var range = SemverRange("1.x || >=2.5.0")
        
        var ver = Semver("0.1.2")
        XCTAssertFalse(ver.satisfies(range))
        ver = Semver("1.1")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("2.4.0")
        XCTAssertFalse(ver.satisfies(range))
        ver = Semver("2.5.1")
        XCTAssertTrue(ver.satisfies(range))
        
        range = SemverRange("~0")
        
        ver = Semver("0.0.9")
        XCTAssertTrue(ver.satisfies(range))
        ver = Semver("1.1.0")
        XCTAssertFalse(ver.satisfies(range))
        
        range = SemverRange(">0.0.1 <=2.0.0")
        
        ver = Semver("1.1")
        XCTAssertTrue(ver.satisfies(range))
    }
}












