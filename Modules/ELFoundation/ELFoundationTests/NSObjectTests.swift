//
//  NSObjectTests.swift
//  ELFoundation
//
//  Created by Sam Grover on 2/1/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELFoundation

class NSObjectTests: XCTestCase {

    class Foo: NSObject {
        
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStaticBundle() {
        XCTAssertTrue("com.walmartlabs.ELFoundationTests" == Foo.bundle().bundleIdentifier!)
    }
    
    func testBundle() {
        let foo = Foo()
        XCTAssertTrue("com.walmartlabs.ELFoundationTests" == foo.bundle().bundleIdentifier!)
    }

}
