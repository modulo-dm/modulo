//
//  DecodableExtensions.swift
//  Codable
//
//  Created by Brandon Sneed on 11/4/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

extension String: ELDecodable {
    public static func decode(_ json: JSON?) throws -> String {
        if let value = json?.string {
            return value
        }
        if json != nil {
            throw ELDecodeError.undecodable
        } else {
            throw ELDecodeError.emptyJSON
        }
    }
}

extension Float: ELDecodable {
    public static func decode(_ json: JSON?) throws -> Float {
        if let value = json?.float {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension Double: ELDecodable {
    public static func decode(_ json: JSON?) throws -> Double {
        if let value = json?.double {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension Int: ELDecodable {
    public static func decode(_ json: JSON?) throws -> Int {
        if let value = json?.int {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension Int64: ELDecodable {
    public static func decode(_ json: JSON?) throws -> Int64 {
        if let value = json?.int64 {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension UInt: ELDecodable {
    public static func decode(_ json: JSON?) throws -> UInt {
        if let value = json?.uInt {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension UInt64: ELDecodable {
    public static func decode(_ json: JSON?) throws -> UInt64 {
        if let value = json?.uInt64 {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension Bool: ELDecodable {
    public static func decode(_ json: JSON?) throws -> Bool {
        if let value = json?.bool {
            return value
        }
        throw ELDecodeError.undecodable
    }
}

extension Decimal: ELDecodable {
    public static func decode(_ json: JSON?) throws -> Decimal {
        if let value = json?.decimal {
            return Decimal(value)
        }
        throw ELDecodeError.undecodable
    }
}

extension Array where Element: ELDecodable {
    public static func decode(_ json: JSON?) throws -> [Element] {
        guard let items = json?.array else {
            throw ELDecodeError.undecodable
        }
        
        var decodedItems = [Element]()
        
        for item in items {
            let decodedItem = try Element.decode(item)
            decodedItems.append(decodedItem)
        }
        
        return decodedItems
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: ELDecodable {
    public static func decode(_ json: JSON?) throws -> [String: JSON] {
        guard let value = json?.dictionary else {
            throw ELDecodeError.undecodable
        }

        return value
    }
}


