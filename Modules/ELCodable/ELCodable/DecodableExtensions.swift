//
//  DecodableExtensions.swift
//  Codable
//
//  Created by Brandon Sneed on 11/4/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

extension String: Decodable {
    public static func decode(_ json: JSON?) throws -> String {
        if let value = json?.string {
            return value
        }
        if json != nil {
            throw DecodeError.undecodable
        } else {
            throw DecodeError.emptyJSON
        }
    }
}

extension Float: Decodable {
    public static func decode(_ json: JSON?) throws -> Float {
        if let value = json?.float {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension Double: Decodable {
    public static func decode(_ json: JSON?) throws -> Double {
        if let value = json?.double {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension Int: Decodable {
    public static func decode(_ json: JSON?) throws -> Int {
        if let value = json?.int {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension Int64: Decodable {
    public static func decode(_ json: JSON?) throws -> Int64 {
        if let value = json?.int64 {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension UInt: Decodable {
    public static func decode(_ json: JSON?) throws -> UInt {
        if let value = json?.uInt {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension UInt64: Decodable {
    public static func decode(_ json: JSON?) throws -> UInt64 {
        if let value = json?.uInt64 {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension Bool: Decodable {
    public static func decode(_ json: JSON?) throws -> Bool {
        if let value = json?.bool {
            return value
        }
        throw DecodeError.undecodable
    }
}

extension Decimal: Decodable {
    public static func decode(_ json: JSON?) throws -> Decimal {
        if let value = json?.decimal {
            return Decimal(value)
        }
        throw DecodeError.undecodable
    }
}

extension Array where Element: Decodable {
    public static func decode(_ json: JSON?) throws -> [Element] {
        guard let items = json?.array else {
            throw DecodeError.undecodable
        }
        
        var decodedItems = [Element]()
        
        for item in items {
            let decodedItem = try Element.decode(item)
            decodedItems.append(decodedItem)
        }
        
        return decodedItems
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Decodable {
    public static func decode(_ json: JSON?) throws -> [String: JSON] {
        guard let value = json?.dictionary else {
            throw DecodeError.undecodable
        }

        return value
    }
}


