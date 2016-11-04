//
//  Encodable.swift
//  Codable
//
//  Created by Brandon Sneed on 11/9/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

public enum EncodeError: Error {
    case unencodable
    case validationUnumplemented
    case validationFailed
}

public protocol Encodable {
    func encode() throws -> JSON
}

public typealias EncodeFormat = Array<(String, JSON)>

public extension Encodable {
    func validateEncode() throws -> Self {
        // do nothing.  user to override.
        throw EncodeError.validationUnumplemented
    }
    
    func encodeToJSON(_ format: EncodeFormat) throws -> JSON {
        var json = JSON()
        for tuple in format {
            json[tuple.0] = tuple.1
        }
        return json
    }
}
