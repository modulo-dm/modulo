//
//  Decodable.swift
//  Codable
//
//  Created by Brandon Sneed on 11/2/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

public enum DecodeError: Error {
    case emptyJSON
    case undecodable
    case validationUnimplemented
    case validationFailed
    case notFound(key: String)
}

public protocol Decodable {
    static func decode(_ json: JSON?) throws -> Self
    func validate() throws -> Self
}

public extension Decodable {
    func validate() throws -> Self {
        // do nothing.  user to override.
        throw DecodeError.validationUnimplemented
        //return self
    }
}
