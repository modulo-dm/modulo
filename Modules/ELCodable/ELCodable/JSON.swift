//
//  JSON2.swift
//  THGModel
//
//  Created by Brandon Sneed on 9/12/15.
//  Copyright © 2015 theholygrail. All rights reserved.
//

import Foundation

public enum JSONError: Error {
    case invalidJSON
}

public enum JSONType: Int {
    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown
}


public struct JSON {
    
    public var object: Any?
    
    public init() {
        self.object = nil
    }
    
    public init(_ object: Any?) {
        self.object = object
    }
    
    public init(json: JSON) {
        self.object = json.object
    }
    
    public init?(data: Data?) {
        if let data = data {
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                self.object = object
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        else {
            return nil
        }
    }
    
    public init?(path: String) {
        let exists = FileManager.default.fileExists(atPath: path)
        if exists {
            let data = try? Data(contentsOf: Foundation.URL(fileURLWithPath: path))
            self.init(data: data)
        } else {
            return nil
        }
    }
    
    /**
    Initialize an instance given a JSON file contained within the bundle.
    
    - parameter bundle: The bundle to attempt to load from.
    - parameter string: A string containing the name of the file to load from resources.
    */
    public init?(bundleClass: AnyClass, filename: String) {
        let bundle = Bundle(for: bundleClass)
        self.init(bundle: bundle, filename: filename)
    }

    public init?(bundle: Bundle, filename: String) {
        let filepath: String? = bundle.path(forResource: filename, ofType: nil)
        if let filepath = filepath {
            self.init(path: filepath)
        } else {
            return nil
        }
    }

    /**
     If the object in question is a dictionary, this will return the value of the key at the specified index.
     If the object is an array, it will return the value at the specified index.
     
     This subscript is currently readonly.
    */
    public subscript(index: Int) -> JSON? {
        get {
            /**
             NSDictionary is used because it currently performs better than a native Swift dictionary.
             The reason for this is that [String : AnyObject] is bridged to NSDictionary deep down the
             call stack, and this bridging operation is relatively expensive. Until Swift is ABI stable
             and/or doesn't require a bridge to Objective-C, NSDictionary will be used here
             */
            if let dictionary = object as? NSDictionary {
                if let keys = dictionary.allKeys as? [String] {
                    let key = keys[index]
                    let value = dictionary[key]
                    if let value = value {
                        return JSON(value as AnyObject?)
                    }
                }
            } else if let array = object as? NSArray {
                let value = array[index]
                return JSON(value as AnyObject?)
            }
            
            return nil
        }
    }
    
    /**
     Returns or sets the key to a given value.
     */
    public subscript(key: String) -> JSON? {
        set {
            if var tempObject = object as? [String : Any] {
                tempObject[key] = newValue?.object
                self.object = tempObject as Any?
            }
            else {
                var tempObject: [String : Any] = [:]
                tempObject[key] = newValue?.object
                self.object = tempObject as Any?
            }
        }
        get {
            /**
            NSDictionary is used because it currently performs better than a native Swift dictionary.
            The reason for this is that [String : AnyObject] is bridged to NSDictionary deep down the
            call stack, and this bridging operation is relatively expensive. Until Swift is ABI stable
            and/or doesn't require a bridge to Objective-C, NSDictionary will be used here
            */
            if let dictionary = object as? NSDictionary {
                let value = dictionary[key]
                if let value = value {
                    return JSON(value as AnyObject?)
                }
            }
            
            return nil
        }
    }
}

extension JSON {
    public func data() -> Data? {
        if let object = object {
            return try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        }
        return nil
    }
}

// MARK: - Types (Debugging)
extension JSON {
    public var type: JSONType {
        if let object = object {
            switch object {
            case is NSString:
                return .string
            case is NSArray:
                return .array
            case is NSDictionary:
                return .dictionary
            case is NSNumber:
                let number = object as! NSNumber
                let type = String(cString: number.objCType)
                // there's no such thing as a 'char' in json, but that's
                // what the serializer types it as.
                if type == "c" {
                    return .bool
                }
                return .number
            case is NSNull:
                return .null
            default:
                return .unknown
            }
        } else {
            return .unknown
        }
    }
    
    public var objectType: String {
        if let object = object {
            return "\(Swift.type(of: object))"
        } else {
            return "Unknown"
        }
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        if let object: Any = object {
            switch object {
            case is String, is NSNumber, is Float, is Double, is Int, is UInt, is Bool: return "\(object)"
            case is [Any], is [String : Any]:
                if let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) {
                    return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? ?? ""
                }
            default: return ""
            }
        }
        
        return "\(String(describing: object))"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - NilLiteralConvertible

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init()
    }
}

// MARK: - StringLiteralConvertible

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value as AnyObject?)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value as AnyObject?)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value as AnyObject?)
    }
}

// MARK: - FloatLiteralConvertible

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value as AnyObject?)
    }
}

// MARK: - IntegerLiteralConvertible

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value as AnyObject?)
    }
}

// MARK: - BooleanLiteralConvertible

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value as AnyObject?)
    }
}

// MARK: - ArrayLiteralConvertible

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AnyObject...) {
        self.init(elements as AnyObject?)
    }
}

// MARK: - DictionaryLiteralConvertible

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, AnyObject)...) {
        var object: [String : AnyObject] = [:]
        
        for (key, value) in elements {
            object[key] = value
        }
        
        self.init(object as AnyObject?)
    }
}

// MARK: - String

extension JSON {
    public var string: String? {
        if let object = object {
            var value: String? = nil
            switch object {
            case is String:
                value = object as? String
            case is NSDecimalNumber:
                value = (object as? NSDecimalNumber)?.stringValue
            case is NSNumber:
                value = (object as? NSNumber)?.stringValue
            default:
                break
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - NSNumber

extension JSON {
    public var number: NSNumber? {
        if let object = object {
            var value: NSNumber? = nil
            switch object {
            case is NSNumber:
                value = object as? NSNumber
            case is String:
                value = NSDecimalNumber(string: object as? String)
            default:
                break
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - NSDecimalNumber

extension JSON {
    public var decimal: NSDecimalNumber? {
        if let object = object {
            var value: NSDecimalNumber? = nil
            switch object {
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue)
                }
                
            case is NSDecimalNumber:
                value = object as? NSDecimalNumber
                
            case is NSNumber:
                // We need to jump through some hoops here. NSNumber's decimalValue doesn't guarantee
                // exactness for float and double types.  See "decimalValue" on NSNumber.
                let number = object as! NSNumber
                let type = String(cString: number.objCType)
                
                // type encodings can be found here:
                // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
                
                switch(type) {
                    // treat the integer based ones the same and just use
                    // the largest type.  No worries here about rounding.
                case "c", "i", "s", "l", "q":
                    value = NSDecimalNumber(value: number.int64Value as Int64)
                    break
                    // do the same with the unsigned types.
                case "C", "I", "S", "L", "Q":
                    value = NSDecimalNumber(value: number.uint64Value as UInt64)
                    break
                    // and again with precision types.
                case "f", "d":
                    value = NSDecimalNumber(value: number.doubleValue as Double)
                    // not sure if we need to handle this, but just in case.
                    // it shouldn't hurt anything.
                case "*":
                    value = NSDecimalNumber(string: number.stringValue)
                    // probably don't need this one either, but oh well.
                case "B":
                    value = NSDecimalNumber(value: number.boolValue as Bool)
                    
                default:
                    break
                }
                
            default:
                break
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - Float

extension JSON {
    public var float: Float? {
        if let object = object {
            var value: Float? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.floatValue
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).floatValue
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - Double

extension JSON {
    public var double: Double? {
        if let object = object {
            var value: Double? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.doubleValue
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).doubleValue
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - Int

extension JSON {
    public var int: Int? {
        if let object = object {
            var value: Int? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.intValue
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).intValue
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
    
    public var int64: Int64? {
        if let object = object {
            var value: Int64? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.int64Value
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).int64Value
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - UInt

extension JSON {
    public var uInt: UInt? {
        if let object = object {
            var value: UInt? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.uintValue
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).uintValue
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
    
    public var uInt64: UInt64? {
        if let object = object {
            var value: UInt64? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.uint64Value
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).uint64Value
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - Bool

extension JSON {
    public var bool: Bool? {
        if let object = object {
            var value: Bool? = nil
            switch object {
            case is NSNumber:
                value = (object as? NSNumber)?.boolValue
            case is String:
                let stringValue = object as? String
                if let stringValue = stringValue {
                    value = NSDecimalNumber(string: stringValue).boolValue
                }
            default:
                break;
            }
            
            return value
        } else {
            return nil
        }
    }
}

// MARK: - NSURL

extension JSON {
    public var URL: Foundation.URL? {
        if let urlString = string {
            return Foundation.URL(string: urlString)
        }
        return nil
    }
}

// MARK: - Array

extension JSON {
    public var array: [JSON]? {
        if let array = object as? [AnyObject] {
            return array.map { JSON($0) }
        }
        return nil
    }
    //public var arrayValue: [JSON] { return array ?? [] }
}

// MARK: - Dictionary

extension JSON {
    public var dictionary: [String : JSON]? {
        if let dictionary = object as? [String : AnyObject] {
            return Dictionary(dictionary.map { ($0, JSON($1)) })
        }
        return nil
    }
    //public var dictionaryValue: [String : JSON] { return dictionary ?? [:] }
}

extension Dictionary {
    fileprivate init(_ pairs: [Element]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }
}

// MARK: - Equatable

extension JSON: Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    if let lhsObject: Any = lhs.object, let rhsObject: Any = rhs.object {
        switch (lhsObject, rhsObject) {
        case (let left as String, let right as String):
            return left == right
        case (let left as Double, let right as Double):
            return left == right
        case (let left as Float, let right as Float):
            return left == right
        case (let left as Int, let right as Int):
            return left == right
        case (let left as Int64, let right as Int64):
            return left == right
        case (let left as UInt, let right as UInt):
            return left == right
        case (let left as UInt64, let right as UInt64):
            return left == right
        case (let left as Bool, let right as Bool):
            return left == right
        case (let left as [Any], let right as [Any]):
            return left.map { JSON($0) } == right.map { JSON ($0) }
        case (let left as [String : Any], let right as [String : Any]):
            return Dictionary(left.map { ($0, JSON($1)) }) == Dictionary(right.map { ($0, JSON($1)) })
        default: return false
        }
    }
    
    return false
}



