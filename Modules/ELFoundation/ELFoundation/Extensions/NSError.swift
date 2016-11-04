//
//  NSError.swift
//  ELFoundation
//
//  Created by Brandon Sneed on 3/25/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

/**
Protocol to make using NSError's in swift easier to use.

Example:

    enum ELMyError: Int, NSErrorEnum {
        case FileNotFound
        case LostACoconut

        public var domain: String {
            return "com.walmartlabs.ELMyError"
        }

        public var errorDescription: String {
            case FileNotFound:
                return "File not found."
            case LostACoconut:
                return "An african swallow stole a coconut."
        }
    }
*/
public protocol NSErrorEnum {
    /// Returns the raw value of the enum.  The enum MUST be an Int.
    var rawValue: Int { get }
    /// Returns the domain of the error enum.  ie: "com.walmartlabs.ELMyError"
    var domain: String { get }
    /// Returns an error description string representing the enum's value.
    var errorDescription: String { get }
}

extension NSError {
    /**
    Convenience init that takes an enum conforming to the NSErrorEnum protocol to build an NSError object.
    
    Example:
    
        let error = NSError(ELMyError.LostACoconut)
    */
    convenience public init(_ code: NSErrorEnum) {
        self.init(domain:code.domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: code.errorDescription])
    }
}
