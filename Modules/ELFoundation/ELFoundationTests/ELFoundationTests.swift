//
//  ELFoundationTests.swift
//  ELFoundationTests
//
//  Created by Brandon Sneed on 2/19/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import XCTest
import ELFoundation

class Foo: NSObject {
    dynamic func returnsOne() -> Int {
        return 1
    }
    
    dynamic class func returnsThree() -> Int {
        return 3
    }
}

extension Foo {
    dynamic func returnsTwo() -> Int {
        return 2
    }
    
    dynamic class func returnsFour() -> Int {
        return 4
    }
}

class Bar {
    
}

class ELFoundationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_swizzleInstanceMethod_replacesImplementationWithSwizzledSelector() {
        let foo = Foo()
        XCTAssertTrue(foo.returnsOne() == 1)
        
        Foo.swizzleInstanceMethod(#selector(Foo.returnsOne), swizzledSelector: #selector(Foo.returnsTwo))
        
        XCTAssertTrue(foo.returnsOne() == 2)
    }
    
    func test_swizzleClassMethod_replacesImplementationWithSwizzledSelector() {
        XCTAssertTrue(Foo.returnsThree() == 3)
        
        Foo.swizzleClassMethod(#selector(Foo.returnsThree), swizzledSelector:  #selector(Foo.returnsFour))
        
        XCTAssertTrue(Foo.returnsThree() == 4)
    }
    
    func testObjectAssociation() {
        let bar = Bar()
        let storedValue = "O'HAI"
        setAssociatedObject(bar, value: storedValue, associativeKey: "AnAssociationkey", policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        let retrievedValue = getAssociatedObject(bar, associativeKey: "AnAssociationkey") as String!
        XCTAssertTrue(retrievedValue == storedValue)
    }
    
}
