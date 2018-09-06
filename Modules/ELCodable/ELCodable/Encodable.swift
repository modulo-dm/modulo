//
//  Encodable.swift
//  Codable
//
//  Created by Brandon Sneed on 11/9/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

public enum ELEncodeError: Error {
    case unencodable
    case validationUnumplemented
    case validationFailed
}

public protocol ELEncodable {
    func encode() throws -> JSON
}

public typealias ELEncodeFormat = Array<(String, JSON)>

public extension ELEncodable {
    func validateEncode() throws -> Self {
        // do nothing.  user to override.
        throw ELEncodeError.validationUnumplemented
    }
    
    func encodeToJSON(_ format: ELEncodeFormat) throws -> JSON {
        var json = JSON()
        for tuple in format {
            json[tuple.0] = tuple.1
        }
        return json
    }
}
