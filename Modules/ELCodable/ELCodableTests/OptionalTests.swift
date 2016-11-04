//
//  OptionalTests.swift
//  ELCodable
//
//  Created by Brandon Sneed on 2/23/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELCodable

struct Data {
    var cart: Cart
}

extension Data: Decodable {
    static func decode(json: JSON?) throws -> Data {
        return try Data(
            cart: json ==> "data"
        )
    }
}

struct Cart {
    var total: Decimal
    var clientTransactionId: String?
    var recordSaleTransactionId: String?
    var approvalNumber: String?
    var authorizerId: String?
}

extension Cart: Decodable {
    static func decode(json: JSON?) throws -> Cart {
        return try Cart(
            total: json ==> "total",
            clientTransactionId: json ==> "clientTransactionId",
            recordSaleTransactionId: json ==> "recordSaleTransactionId",
            approvalNumber: json ==> "approvalNumber",
            authorizerId: json ==> "authorizerId"
        )
    }
}

class OptionalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicOptionals() {
       /*guard let json = JSON(bundleClass: ELCodableTests.self, filename: "OptionalTests.json") else {
            assertionFailure("the json is missing.")
            return
        }
        
        var model: Cart? = nil
        
        guard let json = JSON(responseJson) else {
            
        }
        
        guard let data = json["data"]
        
        guard let jsonDict = json.object as? NSDictionary else {
            assertionFailure("the json is jacked up.")
            return
        }
        
        guard let data = jsonDict["data"] as? NSDictionary else {
            assertionFailure("the data object is missing")
            return
        }
        
        var thrownError: ErrorType? = nil
        
        do {
            model = try Cart.decode(JSON(data))
        } catch let error {
            thrownError = error
        }
        
        if thrownError != nil {
            print(thrownError)
        }
        
        XCTAssertTrue(model != nil, "Cart model is nil!")
        XCTAssertTrue(model?.total == Decimal(818.45), "Total doesn't have the right value!")
        XCTAssertTrue(model?.clientTransactionId == nil)*/
    }

}
