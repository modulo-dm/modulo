//
//  EncodableExtensions.swift
//  Codable
//
//  Created by Brandon Sneed on 11/10/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

extension String: Encodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Float: Encodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Double: Encodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Int: Encodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Int64: Encodable {
    public func encode() throws -> JSON {
        return JSON(NSNumber(value: self as Int64))
    }
}

extension UInt: Encodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension UInt64: Encodable {
    public func encode() throws -> JSON {
        return JSON(NSNumber(value: self as UInt64))
    }
}

extension Bool: Encodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Decimal: Encodable {
    public func encode() throws -> JSON {
        return JSON(self.value)
    }
}

extension Array where Element: Encodable {
    public func encode() throws -> JSON {
        var array = [Any]()
        for item in self {
            let jsonItem = try item.encode()
            if let object = jsonItem.object {
                array.append(object)
            }
        }
        return JSON(array as AnyObject?)
    }
}
