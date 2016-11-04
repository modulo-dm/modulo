//
//  StringTests.swift
//  ELFoundation
//
//  Created by Sam Grover on 2/1/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest

class StringTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGUID() {
        do {
            let regex = try NSRegularExpression(pattern: "^.{8}-.{4}-.{4}-.{4}-.{12}$", options: [])
            let guid = String.GUID()
            let numMatches = regex.numberOfMatches(in: String.GUID(), options: [], range: NSRange(location: 0, length: guid.characters.count))
            XCTAssertTrue(numMatches == 1)
        } catch {
            XCTAssertTrue(false)
        }
    }

}
