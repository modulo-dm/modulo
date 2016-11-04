//
//  NSThreadTests.swift
//  ELFoundation
//
//  Created by Sam Grover on 2/2/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest

class NSThreadTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDateFormatter() {
        let RFC3339TestDate = "1996-12-19T16:39:57-08:00"
        let RFC3339TestDateDescription = "1996-12-20 00:39:57 +0000"
        let RFC3339DateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        let df = Thread.dateFormatter(RFC3339DateFormat)
        let date = df.date(from: RFC3339TestDate)
        XCTAssertTrue(date!.description == RFC3339TestDateDescription)
    }

}
