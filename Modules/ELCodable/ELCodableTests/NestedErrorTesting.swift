//
//  NestedErrorTesting.swift
//  ELCodable
//
//  Created by Brandon Sneed on 1/12/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELCodable
import CoreLocation

// MARK: WMSNGAddress

struct WMSNGAddress: Equatable {
    let street1: String
    let street2: String?
    let city: String
    let state: String
    let zip: String
    let country: String
}

func ==(lhs: WMSNGAddress, rhs: WMSNGAddress) -> Bool {
    return lhs.street1 == rhs.street1 &&
        lhs.street2 == rhs.street2 &&
        lhs.city == rhs.city &&
        lhs.state == rhs.state &&
        lhs.zip == rhs.zip &&
        lhs.country == rhs.country
}

extension WMSNGAddress: Decodable {
    static func decode(json: JSON?) throws -> WMSNGAddress {
        return try WMSNGAddress(street1:    json ==> "street1",
            street2:    json ==> "street2",
            city:       json ==> "cityjij",
            state:      json ==> "state",
            zip:        json ==> "zip",
            country:    json ==> "country")
    }
    
    func validate() throws -> WMSNGAddress {
        // Possibly validate the data here
        return self
    }
}

// MARK: WMSNGStore

struct WMSNGStore: Equatable {
    let storeId: String
    let location: CLLocation
    let phone: String
    let description: String
    let address: WMSNGAddress
}

func ==(lhs: WMSNGStore, rhs: WMSNGStore) -> Bool {
    return lhs.storeId == rhs.storeId &&
        lhs.location == rhs.location &&
        lhs.phone == rhs.phone &&
        lhs.description == rhs.description &&
        lhs.address == rhs.address
}

extension WMSNGStore: Decodable {
    static func decode(json: JSON?) throws -> WMSNGStore {
        let store = try WMSNGStore(storeId: json ==> "storeNumber",
            location: CLLocation(latitude: json ==> "latitude", longitude: json ==> "longitude"),
            phone: json ==> "phone",
            description: json ==> "description",
            address: json ==> "address"
        )
        return store
    }
    
    func validate() throws -> WMSNGStore {
        // Possibly validate the data here
        return self
    }
}


class NestedErrorTesting: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNestedFailure() {
    
        let json = JSON(bundleClass: NestedErrorTesting.self, filename: "NestedErrorTesting.json")
        
        var thrownError: ErrorType? = nil
        
        do {
            let store = try WMSNGStore.decode(json)
            print(store)
        } catch DecodeError.EmptyJSON {
            print("JSON was empty.")
        } catch let error {
            thrownError = error
        }
        
        XCTAssertTrue(thrownError != nil)
        XCTAssertTrue(thrownError.debugDescription == "Optional(ELCodable.DecodeError.NotFound(\"address\"))")
    }

}
