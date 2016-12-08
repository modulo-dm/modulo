//
//  TestGit.swift
//  modulo
//
//  Created by Brandon Sneed on 12/3/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import XCTest
import ELCLI
import ELFoundation
@testable import ModuloKit

class TestGit: XCTestCase {

    override func setUp() {
        super.setUp()
        clearTestRepos()
        print("working path = \(FileManager.workingPath())")
    }
    
    override func tearDown() {
        clearTestRepos()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGettingGitTags() {
        let status = Git().clone("git@github.com:Electrode-iOS/ELWebService.git", path: "ELWebService")
        XCTAssertTrue(status == .success)
        
        let tags = Git().tags("ELWebService")
        print(tags)
        
        Git().remove("ELWebService")
    }

}
