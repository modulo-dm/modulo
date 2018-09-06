//
//  Decimal.swift
//  Decimal
//
//  Created by Brandon Sneed on 11/7/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

public struct Decimal {
    public let value: NSDecimalNumber
    
    /// Create an instance initialized to zero.
    public init() {
        value = NSDecimalNumber.zero
    }
    /// Create an instance initialized to `value`.
    public init(_ value: NSDecimalNumber) {
        self.value = value
    }
    
    public init(_ value: NSNumber) {
        self.value = NSDecimalNumber(decimal: value.decimalValue)
    }
    
    public init(_ value: Float) {
        self.value = NSDecimalNumber(value: value as Float)
    }
    
    public init(_ value: Double) {
        self.value = NSDecimalNumber(value: value as Double)
    }
    
    public init(_ value: String) {
        self.value = NSDecimalNumber(string: value)
    }
}

extension Decimal: CustomStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        return String(reflecting: value)
    }
}

extension Decimal: CustomDebugStringConvertible {
    /// A textual representation of `self`.
    public var debugDescription: String {
        return String(reflecting: value)
    }
}

extension Decimal /*: FloatingPointType*/ { // It complains about _BitsType missing, no idea wtf that is.
    /// The positive infinity.
    public static var infinity: Decimal {
        return Decimal(Double.infinity)
    }
    /// A quiet NaN.
    public static var NaN: Decimal {
        return Decimal(NSDecimalNumber.notANumber)
    }
    /// A quiet NaN.
    public static var quietNaN: Decimal {
        return NaN
    }
    /// `true` iff `self` is negative.
    public var isSignMinus: Bool {
        return ((value as! Double).sign == .minus)
    }
    /// `true` iff `self` is normal (not zero, subnormal, infinity, or
    /// NaN).
    public var isNormal: Bool {
        return (value as! Double).isNormal
    }
    /// `true` iff `self` is zero, subnormal, or normal (not infinity
    /// or NaN).
    public var isFinite: Bool {
        return (value as! Double).isFinite
    }
    /// `true` iff `self` is +0.0 or -0.0.
    public var isZero: Bool {
        return (value as! Double).isZero
    }
    /// `true` iff `self` is subnormal.
    public var isSubnormal: Bool {
        return (value as! Double).isSubnormal
    }
    /// `true` iff `self` is infinity.
    public var isInfinite: Bool {
        return (value as! Double).isInfinite
    }
    /// `true` iff `self` is NaN.
    public var isNaN: Bool {
        return (value as! Double).isNaN
    }
    /// `true` iff `self` is a signaling NaN.
    public var isSignaling: Bool {
        return (value as! Double).isSignalingNaN
    }
}

//extension Decimal: Comparable, Equatable {
//}

// MARK: Equatable
public func ==(lhs: Decimal, rhs: Decimal) -> Bool {
    return lhs.value.compare(rhs.value) == .orderedSame
}

// MARK: Comparable
public func <(lhs: Decimal, rhs: Decimal) -> Bool {
    return lhs.value.compare(rhs.value) == .orderedAscending
}

public func <=(lhs: Decimal, rhs: Decimal) -> Bool {
    let result = lhs.value.compare(rhs.value)
    if result == .orderedAscending {
        return true
    } else if result == .orderedSame {
        return true
    }
    return false
}

public func >=(lhs: Decimal, rhs: Decimal) -> Bool {
    let result = lhs.value.compare(rhs.value)
    if result == .orderedDescending {
        return true
    } else if result == .orderedSame {
        return true
    }
    return false
}

public func >(lhs: Decimal, rhs: Decimal) -> Bool {
    return lhs.value.compare(rhs.value) == .orderedDescending
}

extension Decimal: Hashable {
    /// The hash value.
    ///
    /// **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
    ///
    /// - Note: The hash value is not guaranteed to be stable across
    ///   different invocations of the same program.  Do not persist the
    ///   hash value across program runs.
    public var hashValue: Int {
        return value.hash
    }
}

extension Decimal: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.value = NSDecimalNumber(value: value as Int)
    }
}

extension Decimal: SignedNumeric & Comparable {
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.value = NSDecimalNumber.init(value: Int(source))
    }

    public var magnitude: Decimal {
        return Decimal.abs(self)
    }

    /// Returns the absolute value of `x`.
    public static func abs(_ x: Decimal) -> Decimal {
        if x.value.compare(NSDecimalNumber.zero) == .orderedAscending {
            // number is neg, multiply by -1
            let negOne = NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
            return Decimal(x.value.multiplying(by: negOne, withBehavior: nil))
        } else {
            return x
        }
    }
}

extension Decimal {
    public init(_ v: UInt8) {
        value = NSDecimalNumber(value: v as UInt8)
    }
    public init(_ v: Int8) {
        value = NSDecimalNumber(value: v as Int8)
    }
    public init(_ v: UInt16) {
        value = NSDecimalNumber(value: v as UInt16)
    }
    public init(_ v: Int16) {
        value = NSDecimalNumber(value: v as Int16)
    }
    public init(_ v: UInt32) {
        value = NSDecimalNumber(value: v as UInt32)
    }
    public init(_ v: Int32) {
        value = NSDecimalNumber(value: v as Int32)
    }
    public init(_ v: UInt64) {
        value = NSDecimalNumber(value: v as UInt64)
    }
    public init(_ v: Int64) {
        value = NSDecimalNumber(value: v as Int64)
    }
    public init(_ v: UInt) {
        value = NSDecimalNumber(value: v as UInt)
    }
    public init(_ v: Int) {
        value = NSDecimalNumber(value: v as Int)
    }
}

// MARK: Addition operators

public func +(lhs: Decimal, rhs: Decimal) -> Decimal {
    return Decimal(lhs.value.adding(rhs.value))
}

public prefix func ++(lhs: Decimal) -> Decimal {
    return Decimal(lhs.value.adding(NSDecimalNumber.one))
}

public postfix func ++(lhs: inout Decimal) -> Decimal {
    lhs = Decimal(lhs.value.adding(NSDecimalNumber.one))
    return lhs
}

public func +=(lhs: inout Decimal, rhs: Decimal) {
    lhs = Decimal(lhs.value.adding(rhs.value))
}

public func +=(lhs: inout Decimal, rhs: Int) {
    lhs = Decimal(lhs.value.adding(NSDecimalNumber(value: rhs as Int)))
}

public func +=(lhs: inout Decimal, rhs: Double) {
    lhs = Decimal(lhs.value.adding(NSDecimalNumber(value: rhs as Double)))
}

// MARK: Subtraction operators

public prefix func -(x: Decimal) -> Decimal {
    return Decimal(x.value.multiplying(by: NSDecimalNumber(value: -1 as Int)))
}

public func -(lhs: Decimal, rhs: Decimal) -> Decimal {
    return Decimal(lhs.value.subtracting(rhs.value))
}

public prefix func --(lhs: Decimal) -> Decimal {
    return Decimal(lhs.value.subtracting(NSDecimalNumber.one))
}

public postfix func --(lhs: inout Decimal) -> Decimal {
    lhs = Decimal(lhs.value.subtracting(NSDecimalNumber.one))
    return lhs
}

public func -=(lhs: inout Decimal, rhs: Decimal) {
    lhs = Decimal(lhs.value.subtracting(rhs.value))
}

public func -=(lhs: inout Decimal, rhs: Int) {
    lhs = Decimal(lhs.value.subtracting(NSDecimalNumber(value: rhs as Int)))
}

public func -=(lhs: inout Decimal, rhs: Double) {
    lhs = Decimal(lhs.value.subtracting(NSDecimalNumber(value: rhs as Double)))
}


// MARK: Multiplication operators

public func *(lhs: Decimal, rhs: Decimal) -> Decimal {
    return Decimal(lhs.value.multiplying(by: rhs.value))
}

public func *=(lhs: inout Decimal, rhs: Decimal) {
    lhs = Decimal(lhs.value.multiplying(by: rhs.value))
}

public func *=(lhs: inout Decimal, rhs: Int) {
    lhs = Decimal(lhs.value.multiplying(by: NSDecimalNumber(value: rhs as Int)))
}

public func *=(lhs: inout Decimal, rhs: Double) {
    lhs = Decimal(lhs.value.multiplying(by: NSDecimalNumber(value: rhs as Double)))
}

// MARK: Division operators

public func /(lhs: Decimal, rhs: Decimal) -> Decimal {
    return Decimal(lhs.value.dividing(by: rhs.value))
}

public func /=(lhs: inout Decimal, rhs: Decimal) {
    lhs = Decimal(lhs.value.dividing(by: rhs.value))
}

public func /=(lhs: inout Decimal, rhs: Int) {
    lhs = Decimal(lhs.value.dividing(by: NSDecimalNumber(value: rhs as Int)))
}

public func /=(lhs: inout Decimal, rhs: Double) {
    lhs = Decimal(lhs.value.dividing(by: NSDecimalNumber(value: rhs as Double)))
}

// MARK: Power-of operators

public func ^(lhs: Decimal, rhs: Int) -> Decimal {
    return Decimal(lhs.value.raising(toPower: rhs))
}

extension Decimal: Strideable {
    /// Returns a stride `x` such that `self.advancedBy(x)` approximates
    /// `other`.
    ///
    /// - Complexity: O(1).
    public func distance(to other: Decimal) -> Decimal {
        return self - other
    }
    /// Returns a `Self` `x` such that `self.distanceTo(x)` approximates
    /// `n`.
    ///
    /// - Complexity: O(1).
    public func advanced(by amount: Decimal) -> Decimal {
        return self + amount
    }
    
}


