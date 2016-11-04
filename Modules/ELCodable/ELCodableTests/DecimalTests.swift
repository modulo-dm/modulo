//
//  DecimalTests.swift
//  ELCodable
//
//  Created by Brandon Sneed on 1/15/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELCodable

class DecimalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEquality() {
        let doubleValue: Double = 264.91
        let jsonValue = JSON(doubleValue)
        
        let subtotal = Decimal(jsonValue.decimal!)
        
        XCTAssertEqual(subtotal, Decimal(doubleValue))
    }
    
}





