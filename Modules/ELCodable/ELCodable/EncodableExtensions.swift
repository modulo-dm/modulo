//
//  EncodableExtensions.swift
//  Codable
//
//  Created by Brandon Sneed on 11/10/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

extension String: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Float: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Double: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Int: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Int64: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(NSNumber(value: self as Int64))
    }
}

extension UInt: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension UInt64: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(NSNumber(value: self as UInt64))
    }
}

extension Bool: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self as AnyObject?)
    }
}

extension Decimal: ELEncodable {
    public func encode() throws -> JSON {
        return JSON(self.value)
    }
}

extension Array where Element: ELEncodable {
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
