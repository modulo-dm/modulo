//
//  NSURLTests.swift
//  ELFoundation
//
//  Created by Brandon Sneed on 4/15/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELFoundation

class NSURLTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testQueryDictionary() {
        let url = URL(string: "http://blah.com/something?key1=value1&key2=value2&key3=this%20be%20value%203%2C%20y0")
        
        let dict = url!.queryDictionary!
        
        XCTAssertTrue(dict["key1"] == "value1")
        XCTAssertTrue(dict["key2"] == "value2")
        XCTAssertTrue(dict["key3"] == "this be value 3, y0")
    }

}
