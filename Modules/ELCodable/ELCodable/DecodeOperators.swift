//
//  DecodeOperators.swift
//  Codable
//
//  Created by Brandon Sneed on 11/3/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

//infix operator ==> { associativity right precedence 150 }

infix operator ==>  : DecodingPrecedence

precedencegroup DecodingPrecedence {
    associativity: right
    higherThan: CastingPrecedence
}

public func ==> <T: Decodable>(lhs: JSON?, rhs: String) throws -> T {
    guard let json = lhs else {
        throw DecodeError.emptyJSON
    }
    
    do {
        let value: T? = try? T.decode(json[rhs])
        if let value = value {
            return value
        } else {
            throw DecodeError.notFound(key: rhs)
        }
    } catch let error {
        throw error
    }
}

public func ==> <T: Decodable>(lhs: JSON?, rhs: String) throws -> [T] {
    guard let json = lhs else {
        throw DecodeError.emptyJSON
    }
    
    guard let array = json[rhs]?.array else {
        throw DecodeError.notFound(key: rhs)
    }
    
    var results = [T]()
    
    for json in array {
        // will throw a NotFound() if this decode fails.
        let value = try T.decode(json)
        results.append(value)
    }
    
    return results
}

public func ==> <T: Decodable>(lhs: JSON?, rhs: String) throws -> T? {
    guard let json = lhs else {
        throw DecodeError.emptyJSON
    }
    
    let value = try? T.decode(json[rhs])
    if let value = value {
        return value
    } else {
        return nil
    }
}

public func ==> <T: Decodable>(lhs: JSON?, rhs: String) throws -> [T]? {
    guard let json = lhs else {
        throw DecodeError.emptyJSON
    }
    
    guard let array = json[rhs]?.array else {
        return nil
    }
    
    var results = [T]()
    
    for json in array {
        if let value = try? T.decode(json) {
            results.append(value)
        }
    }
    
    return results
}

