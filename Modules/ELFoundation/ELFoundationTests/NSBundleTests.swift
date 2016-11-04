//
//  NSBundleTests.swift
//  ELFoundation
//
//  Created by Steven Riggins on 7/7/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import XCTest
import ELFoundation

class NSBundleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReverseBundleIdentifier() {
        let bundle = Bundle(identifier: "com.walmartlabs.ELFoundation")
        let reverseIdentifier = bundle?.reverseBundleIdentifier()
        
        XCTAssertTrue(reverseIdentifier == "ELFoundation.walmartlabs.com")
    }
    
}
