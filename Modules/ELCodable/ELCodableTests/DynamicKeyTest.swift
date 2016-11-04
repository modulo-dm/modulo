//
//  DynamicKeyTest.swift
//  ELCodable
//
//  Created by Brandon Sneed on 7/21/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELCodable

struct MyData {
    let availableInStore: Int
    let format: String
    let identifier: String
    let location: LocationData
    let name: String
    let packagePrice: Decimal
    let unitPrice: Decimal
}

extension MyData: Decodable {
    static func decode(json: JSON?) throws -> MyData {
        let buriedJson = json?["data"]?[0]

        return try MyData(
            availableInStore: buriedJson ==> "availabilityInStore",
            format: buriedJson ==> "format",
            identifier: buriedJson ==> "identifier",
            location: buriedJson ==> "location",
            name: buriedJson ==> "name",
            packagePrice: buriedJson ==> "packagePrice",
            unitPrice: buriedJson ==> "unitPrice"
        )
    }
}

struct LocationData {
    let aisle: String
    let section: String
    let zone: String
}

extension LocationData: Decodable {
    static func decode(json: JSON?) throws -> LocationData {
        return try LocationData(
            aisle: json ==> "aisle",
            section: json ==> "section",
            zone: json ==> "zone"
        )
    }
}



class DynamicKeyTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRandomKeyExtraction() {
        guard let json = JSON(bundleClass: ELCodableTests.self, filename: "DynamicKeyedData.json") else {
            assertionFailure("the json is missing.")
            return
        }
        
        var thrownError: ErrorType? = nil
        
        do {
            let model = try MyData.decode(json)
            XCTAssertTrue(model.availableInStore == 15)
            XCTAssertTrue(model.format == "EAN13")
            XCTAssertTrue(model.location.zone == "A")
            XCTAssertTrue(model.unitPrice == Decimal(3.32))
        } catch let error {
            thrownError = error
        }
        
        XCTAssertTrue(thrownError == nil)
    }
}
