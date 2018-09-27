//
//  TestDefaults.swift
//  ModuloKitTests
//
//  Created by Daniel Miedema on 9/25/18.
//  Copyright © 2018 TheHolyGrail. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
import ELCodable // for JSON
@testable import ModuloKit

class TestDefaults: XCTestCase {
    let modulo = Modulo()

    // MARK: - Setup
    override func setUp() {
        super.setUp()

        moduloReset()
    }

    // MARK: - Migration
    func testMigrationFromNoOptionsInModuloFile() {
        let moduleFileJSONDictionary = [
            "dependencies": [],
            "module": false,
            "name": "best project"
            ] as [String : Any]
        do {
            let moduleSpec = try spec(from: moduleFileJSONDictionary)
            let options = moduleSpec.options
            // validate defaults
            XCTAssertTrue(options.alwaysVerbose == false)
            XCTAssertTrue(options.depdencyInstallationPath == "modules")
        } catch {
            XCTFail("Failed with error \(error)")
        }
    }

    // MARK: - Bad Input
    func testGarbageValuesInModuloFileResultInSaneDefaults() {
        let moduleFileJSONDictionary = [
            "dependencies": [],
            "module": false,
            "name": "best project",
            "options": [
                "alwaysVerbose": "lolgarbage",
                "depdencyInstallationPath": ["fart": "toot"],
                "invalid_key": true,
            ]
            ] as [String : Any]
        do {
            let moduleSpec = try spec(from: moduleFileJSONDictionary)
            let options = moduleSpec.options
            // validate defaults since we fed it garbage
            XCTAssertTrue(options.alwaysVerbose == false)
            XCTAssertTrue(options.depdencyInstallationPath == "modules")
        } catch {
            XCTFail("Failed with error \(error)")
        }
    }

    // MARK: - Loaded from module file
    func testOptionsAreParsedFromModuleFile() {
        let directoryPath = "only-the-best-dependencies-live-here"
        let moduleFileJSONDictionary = [
            "dependencies": [],
            "module": false,
            "name": "best project",
            "options": [
                "alwaysVerbose": true,
                "depdencyInstallationPath": directoryPath,
            ]
            ] as [String : Any]

        do {
            let moduleSpec = try spec(from: moduleFileJSONDictionary)
            let options = moduleSpec.options
            XCTAssertTrue(options.alwaysVerbose == true)
            XCTAssertTrue(options.depdencyInstallationPath == directoryPath)
        } catch {
            XCTFail("Failed with error \(error)")
        }
    }

    // MARK: - CLI API
    func testReadingAllDefaults() {
        _ = Modulo()
        moduloReset()

        let result = Modulo.run(["defaults"])

        // ideally we'd capture output (stdout) somehow
        // and verify our output is what we want but since
        // i can't see a nice way to do that with ELCLI
        // we'll just verify success instead.

        XCTAssertTrue(result == .success)
    }

    func testSettingDefault() {
        _ = Modulo()
        moduloReset()
        XCTAssertFalse(State.instance.options.alwaysVerbose)
        let verboseResult = Modulo.run(["defaults", "--set", "--alwaysVerbose", "true"])
        XCTAssertTrue(verboseResult == .success)
        XCTAssertTrue(State.instance.options.alwaysVerbose)

        let directoryResult = Modulo.run(["defaults", "--set", "--moduleFolder", "bestDIR"])
        XCTAssertTrue(directoryResult == .success)
        XCTAssertTrue(State.instance.options.depdencyInstallationPath == "bestDIR")
    }

    func testFailsIfSettingBadDefault() {
        _ = Modulo()
        moduloReset()

        xctAssertThrows({
            _ = Modulo.run(["defaults", "--set", "--NoTheRightValue", "badValue.BadMe."])
        }, "Running `defaults --set` with a bad flag/value did not fail")
    }

    func testSettingDefaultWithBadValue() {
        _ = Modulo()
        moduloReset()
        State.instance.options.alwaysVerbose = true

        let badVerboseResult = Modulo.run(["defaults", "--set", "--alwaysVerbose", "ohSoVerbose"])
        XCTAssertTrue(badVerboseResult == .success)
        XCTAssertFalse(State.instance.options.alwaysVerbose)
    }

    func testSettingWithNoKey() {
        _ = Modulo()
        moduloReset()

        let initialVerbose = State.instance.options.alwaysVerbose
        let initialPath = State.instance.options.depdencyInstallationPath
        let result = Modulo.run(["defaults", "--set"])
        XCTAssertTrue(result == .success, "Even though we set nothing, we shoud succeed with some output for the user")
        XCTAssertTrue(initialVerbose == State.instance.options.alwaysVerbose)
        XCTAssertTrue(initialPath == State.instance.options.depdencyInstallationPath)
    }
}

// MARK: -  Test Helpers
extension TestDefaults {
    func spec(from dictionary: [String: Any]) throws -> ModuleSpec {
        let moduleFileJSONData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        guard let moduleFileJSON = JSON(data: moduleFileJSONData) else {
            throw NSError(domain: "TestDefaults",
                          code: -1,
                          userInfo: [
                            NSLocalizedDescriptionKey: "Failed to create JSON from Data"
                ])
        }
        return try ModuleSpec.decode(moduleFileJSON)
    }
}
