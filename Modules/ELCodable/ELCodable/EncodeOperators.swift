//
//  EncodeOperators.swift
//  Codable
//
//  Created by Brandon Sneed on 11/10/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

//infix operator <== { associativity right precedence 150 }

infix operator <== : EncodingPrecedence

precedencegroup EncodingPrecedence {
    associativity: right
    higherThan: CastingPrecedence
}

public func <== <T: Encodable>(lhs: String, rhs: T) throws -> (String, JSON) {
    let value = try? rhs.encode()
    if let value = value {
        return (lhs, value)
    } else {
        throw EncodeError.unencodable
    }
}

public func <== <T: Encodable>(lhs: String, rhs: [T]) throws -> (String, JSON) {
    let value = try? rhs.encode()
    if let value = value {
        return (lhs, value)
    } else {
        throw EncodeError.unencodable
    }
}

public func <== <T: Encodable>(lhs: String, rhs: T?) throws -> (String, JSON) {
    if rhs == nil {
        return (lhs, JSON())
    }
    
    let value = try? rhs?.encode()
    if let value = value {
        return (lhs, value!)
    } else {
        return (lhs, JSON())
    }
}

public func <== <T: Encodable>(lhs: String, rhs: [T]?) throws -> (String, JSON) {
    if rhs == nil {
        return (lhs, JSON())
    }
    
    let value = try? rhs?.encode()
    if let value = value {
        return (lhs, value!)
    } else {
        return (lhs, JSON())
    }
}
