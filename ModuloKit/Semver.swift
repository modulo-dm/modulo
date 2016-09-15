//
//  Semver.swift
//  modulo
//
//  Created by Brandon Sneed on 8/9/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

internal enum SemverPart: Int {
    case Breaking
    case Feature
    case Fix
    
    case Major
    case Minor
    case Patch
    
    case PrimaryPartial
    case SecondaryPartial
    
    case LeftMostNonZero
}

// MARK: Semver Public interface

public struct Semver {
    public private(set) var prefix: String? = nil
    
    public private(set) var breaking: Int
    public private(set) var feature: Int
    public private(set) var fix: Int
    
    public var major: Int {
        return breaking
    }
    
    public var minor: Int {
        return feature
    }
    
    public var patch: Int {
        return fix
    }
    
    public private(set) var preRelease: String? = nil
    public private(set) var build: String? = nil
    
    public private(set) var valid = true
    public var partial: Bool {
        return breaking == -1 || feature == -1 || fix == -1
    }
    
    public init(_ value: String) {
        original = value

        breaking = -1
        feature = -1
        fix = -1
        
        parse(value)
    }
    
    public var stringValue: String {
        if let pre = preRelease {
            return "\(breaking).\(feature).\(fix)-\(pre)"
        } else {
            return "\(breaking).\(feature).\(fix)"
        }
    }
    
    // internal use only
    internal let original: String
    internal var preReleaseVersionData = [Int]()
}

// MARK: Regex string extension

private let CleanRegex = "([0-9]+)\\.([0-9]+)\\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+[0-9A-Za-z-\\.]+)?"
private let PrefixRegex = "^[^[0-9]*]*"
private let VersionRegex = "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)"
private let PreReleaseRegex = "(?:-((?:[0-9]+|\\d*[a-zA-Z-][a-zA-Z0-9-]*)(?:\\.(?:[0-9]+|\\d*[a-zA-Z-][a-zA-Z0-9-]*))*))"
private let BuildRegex = "(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-])*))"
private let NumberRegex = "([0-9]+)"
private let VersionXRegex = "([0-9]+|x|x|\\*)"

/*private let CleanRegex = "([0-9]|x|\\*+)\\.([0-9]|x|\\*+)\\.([0-9]|x|\\*+)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+[0-9A-Za-z-\\.]+)?"
private let PrefixRegex = "^[^[0-9]*]*"
private let VersionRegex = "(0|[1-9]|[X,x,\\*]\\d*)\\.(0|[1-9]|[X,x,\\*]\\d*)\\.(0|[1-9]|[X,x,\\*]\\d*)"
private let PreReleaseRegex = "(?:-((?:[0-9]+|\\d*[a-zA-Z-][a-zA-Z0-9-]*)(?:\\.(?:[0-9]+|\\d*[a-zA-Z-][a-zA-Z0-9-]*))*))"
private let BuildRegex = "(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-])*))"
private let NumberRegex = "([0-9]+)"
private let VersionXRegex = "([0-9]+|x|x|\\*)"*/

extension String {
    func matchesForRegex(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range) }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: Internal stuff

internal enum SemverComparison {
    case Equal
    case GreaterThan
    case LessThan
    case Unknown
}

extension Semver {
    private mutating func parse(value: String) {
        
        // it ain't got enough characters, ditch.
        guard value.characters.count > 0 else {
            valid = false
            return
        }
        
        let xMatches = value.matchesForRegex(VersionXRegex)
        
        let tempValue = clean(value)

        let versionMatches = tempValue.matchesForRegex(VersionRegex)
        let preReleaseMatches = tempValue.matchesForRegex(PreReleaseRegex)
        let buildMatches = tempValue.matchesForRegex(BuildRegex)
        
        if versionMatches.count > 0 {
            // force unwrap, because our regex wouldn't have matched it if there weren't
            // at least 3 or they weren't all numbers.
            let versionComponents = versionMatches[0].componentsSeparatedByString(".")
            breaking = Int(versionComponents[0]) ?? -1
            feature = Int(versionComponents[1]) ?? -1
            fix = Int(versionComponents[2]) ?? -1
            
            if preReleaseMatches.count > 0 {
                // remove the leading -, it *will* be there due to the regex.
                preRelease = String(preReleaseMatches[0].characters.dropFirst())
                // now pick up any version data sitting in pre release.
                let preReleaseVersionMatches = preRelease!.matchesForRegex(NumberRegex)
                preReleaseVersionMatches.forEach { (number) in
                    preReleaseVersionData.append(Int(number)!)
                }
            }
            
            if buildMatches.count > 0 {
                // remove the leading +, it *will* be there due to the regex.
                build = String(buildMatches[0].characters.dropFirst())
            }
            
        } else {
            // we didn't have any version matches, maybe it's got x-ranges in it.
            if xMatches.count > 0 {
                for (index, element) in xMatches.enumerate() {
                    let value = Int(element)
                    
                    if index == 0 {
                        if let v = value {
                            breaking = v
                        }
                    } else if index == 1 {
                        if let v = value {
                            feature = v
                        }
                    }
                    if index == 2 {
                        if let v = value {
                            fix = v
                        }
                    }
                }
            } else {
                valid = false
                return
            }
        }

        prefix = prefix(original)
    }
    
    private func prefix(value: String) -> String? {
        let prefix = value.matchesForRegex(PrefixRegex)
        
        if prefix.count == 1 {
            return prefix[0]
        }
        
        return nil
    }
    
    private func clean(value: String) -> String {
        let cleanMatches = value.matchesForRegex(CleanRegex)
        
        if cleanMatches.count == 1 {
            return cleanMatches[0]
        }
        
        return ""
    }
    
    private func elements() -> [Int] {
        var items = [Int]()
        
        items.append(breaking)
        items.append(feature)
        items.append(fix)
        
        preReleaseVersionData.forEach { (value) in
            items.append(value)
        }
        
        return items
    }
    
    private func comparison(ver: Semver) -> SemverComparison {
        var result = SemverComparison.Unknown
        
        let this = elements()
        let that = ver.elements()
        
        if this == that {
            return .Equal
        }
        
        for (index, element) in this.enumerate() {
            if index < that.count {
                let thatElement = that[index]
                if element > thatElement {
                    result = .GreaterThan
                    break
                }
                if element < thatElement {
                    result = .LessThan
                    break
                }
            } else {
                break
            }
        }

        return result
    }
}

extension Semver {
    internal mutating func normalize() {
        if partial {
            if breaking == -1 {
                breaking = 0
            }
            if feature == -1 {
                feature = 0
            }
            if fix == -1 {
                fix = 0
            }
        }
    }
    
    internal mutating func increment(part: SemverPart) {
        switch part {
        case .Major:
            fallthrough
        case .Breaking:
            breaking += 1
            feature = 0
            fix = 0
            
        case .Minor:
            fallthrough
        case .Feature:
            feature += 1
            fix = 0
            
        case .Patch:
            fallthrough
        case .Fix:
            fix += 1
           
        // increment the first partial we come across as if it were the 1st in a range
        case .PrimaryPartial:
            if breaking == -1 {
                breaking == 0
                feature = 0
                fix = 0
            } else if feature == -1 {
                feature = 0
                fix = 0
            } else if fix == -1 {
                fix = 0
            } else {
                return
            }

        // increment the first partial we come across as if it were the 2nd in a range
        case .SecondaryPartial:
            if breaking == -1 {
                breaking == 1
                feature = 0
                fix = 0
            } else if feature == -1 {
                breaking += 1
                feature = 0
                fix = 0
            } else if fix == -1 {
                feature += 1
                fix = 0
            } else {
                return
            }
            
        case .LeftMostNonZero:
            let parts = [breaking, feature, fix]
            var partsOut = [Int]()
            var gotFirst = false
            for part in parts {
                if part == 0 {
                    partsOut.append(part)
                } else if gotFirst == false {
                    partsOut.append(part + 1)
                    gotFirst = true
                } else {
                    partsOut.append(part)
                }
            }
            
            breaking = partsOut[0]
            feature = partsOut[1]
            fix = partsOut[2]
            
            // everything was zero's, so increment feature.
            if gotFirst == false {
                feature += 1
            }
        }
        
        preReleaseVersionData.removeAll()
        preRelease = nil
        build = nil
    }
}

// MARK: Comparison operators

extension Semver: Equatable { }

public func ==(lhs: Semver, rhs: Semver) -> Bool {
    return lhs.comparison(rhs) == .Equal
}

public func >(lhs: Semver, rhs: Semver) -> Bool {
    return lhs.comparison(rhs) == .GreaterThan
}

public func <(lhs: Semver, rhs: Semver) -> Bool {
    return lhs.comparison(rhs) == .LessThan
}

public func >=(lhs: Semver, rhs: Semver) -> Bool {
    let result = lhs.comparison(rhs)
    return result == .Equal || result == .GreaterThan
}

public func <=(lhs: Semver, rhs: Semver) -> Bool {
    let result = lhs.comparison(rhs)
    return result == .Equal || result == .LessThan
}

// MARK: SemverComparator enum

internal enum SemverComparator: CustomStringConvertible {
    case GreaterThan(version: Semver)
    case LessThan(version: Semver)
    case GreaterThanOrEqual(version: Semver)
    case LessThanOrEqual(version: Semver)
    
    var description: String {
        switch self {
        case .GreaterThan(let version):
            return ">\(version.stringValue)"
            
        case .LessThan(let version):
            return "<\(version.stringValue)"
            
        case .GreaterThanOrEqual(let version):
            return ">=\(version.stringValue)"
            
        case .LessThanOrEqual(let version):
            return "<=\(version.stringValue)"
        }
    }
}

// MARK: SemverRange public interface

internal enum Token: String {
    case LessThan = "<"
    case GreaterThan = ">"
    case LessThanOrEqual = "<="
    case GreaterThanOrEqual = ">="
    case Caret = "^"
    case Tilde = "~"
    case Dash = " - "
}

public struct SemverRange {
    public private(set) var valid = true
    
    internal var comparators = [SemverComparator]()
    
    public init(_ value: String) {
        original = value
        
        parse()
    }
    
    private mutating func parse() {
        let parts = original.componentsSeparatedByString("||")
        let set = parts.map { (section) -> String in
            let result = section.clean()
            print("section = \(result)")
            return result
        }
        
        print(set)
        
        comparators = transmogrify(set)
    }
    
    private func transmogrify(set: [String]) -> [SemverComparator] {
        var resultSet = [SemverComparator]()
        
        // don't include dash since we don't strip it.
        let rangeTokens = [Token.LessThan.rawValue,
                           Token.GreaterThan.rawValue,
                           Token.LessThanOrEqual.rawValue,
                           Token.GreaterThanOrEqual.rawValue,
                           Token.Caret.rawValue,
                           Token.Tilde.rawValue]
        
        // look for the range marker ' - '
        for item in set {
            if item.containsString(Token.Dash.rawValue) {
                // -
                // now we need to split it in two.
                let pieces = item.componentsSeparatedByString(Token.Dash.rawValue).map { (piece) -> String in
                    return piece.stringByRemovingAll(rangeTokens)
                }
                
                if pieces.count == 2 {
                    var ver1 = Semver(pieces[0])
                    var ver2 = Semver(pieces[1])
                    
                    // if we have a partial version, bump it accordingly
                    if ver1.partial {
                        ver1.increment(.PrimaryPartial)
                    }
                    // we add it the same way, whether it's partial or not.
                    resultSet.append(.GreaterThanOrEqual(version: ver1))
                    
                    if ver2.partial {
                        ver2.increment(.SecondaryPartial)
                        resultSet.append(.LessThan(version: ver2))
                    } else {
                        resultSet.append(.LessThanOrEqual(version: ver2))
                    }
                }
            } else if item.containsString(Token.Tilde.rawValue) {
                // ~
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                var ver2 = Semver(piece)
                
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.GreaterThanOrEqual(version: ver1))
                
                if ver2.partial {
                    ver2.increment(.SecondaryPartial)
                } else {
                    ver2.increment(.Feature)
                }
                resultSet.append(.LessThan(version: ver2))
            } else if item.containsString(Token.Caret.rawValue) {
                // ^
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                var ver2 = Semver(piece)
                
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.GreaterThanOrEqual(version: ver1))
                
                if ver2.partial {
                    ver2.normalize()
                }
                ver2.increment(.LeftMostNonZero)
                resultSet.append(.LessThan(version: ver2))
            } else if item.containsString(Token.LessThanOrEqual.rawValue) {
                // <=
                let piece = item.stringByRemovingAll(rangeTokens)
                let ver1 = Semver(piece)
                resultSet.append(.LessThanOrEqual(version: ver1))
            } else if item.containsString(Token.GreaterThanOrEqual.rawValue) {
                // >=
                let piece = item.stringByRemovingAll(rangeTokens)
                let ver1 = Semver(piece)
                resultSet.append(.GreaterThanOrEqual(version: ver1))
            } else if item.containsString(Token.LessThan.rawValue) {
                // <
                let piece = item.stringByRemovingAll(rangeTokens)
                let ver1 = Semver(piece)
                resultSet.append(.LessThan(version: ver1))
            } else if item.containsString(Token.GreaterThan.rawValue) {
                // >
                let piece = item.stringByRemovingAll(rangeTokens)
                let ver1 = Semver(piece)
                resultSet.append(.GreaterThan(version: ver1))
            } else {
                // *, x, X
                let piece = item
                var ver1 = Semver(piece)
                var ver2 = Semver(piece)
                
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.GreaterThanOrEqual(version: ver1))
                
                if ver2.partial {
                    ver2.normalize()
                    ver2.increment(.LeftMostNonZero)
                    resultSet.append(.LessThan(version: ver2))
                }
            }
        }
        
        return resultSet
    }

    internal var simplified = [String]()
    internal let original: String
    
}

// MARK: Range matching

extension Semver {
    public func satisfies(range: SemverRange) -> Bool {
        return false
    }
}

extension SemverRange {
    public func compatible(versions: [Semver]) -> [Semver] {
        let result = [Semver]()
        
        return result
    }
}

