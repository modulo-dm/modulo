//
//  Decimal.swift
//  Decimal
//
//  Created by Brandon Sneed on 11/7/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

extension Decimal {
    public var value: NSDecimalNumber {
        get {
            return (self as NSDecimalNumber)
        }
    }
}
