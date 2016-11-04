//
//  KeyPathTests.swift
//  ELCodable
//
//  Created by Brandon Sneed on 3/15/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import XCTest
import ELCodable

struct VersionModel {
    let minVersion: String
    let url: String
    let version: String
}

extension VersionModel: Decodable {
    static func decode(json: JSON?) throws -> VersionModel {
        return try VersionModel(
            minVersion: json?["appVersion"]?["iOS"] ==> "minVersion",
            url: json?["appVersion"]?["iOS"] ==> "url",
            version: json?["appVersion"]?["iOS"] ==> "version"
        )
    }
}

class KeyPathTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUglyKeyPath() {
        guard let json = JSON(bundleClass: ELCodableTests.self, filename: "jsontest_models.json") else {
            assertionFailure("the json is missing.")
            return
        }
        
        var thrownError: ErrorType? = nil
        
        do {
            let model = try VersionModel.decode(json)
            XCTAssertTrue(model.minVersion == "0.1.4")
            XCTAssertTrue(model.url == "https://walmart.com/change-me")
            XCTAssertTrue(model.version == "0.1.4")
        } catch let error {
            thrownError = error
        }

        XCTAssertTrue(thrownError == nil)
    }
    
}
