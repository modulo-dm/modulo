//
//  Semver.swift
//  modulo
//
//  Created by Brandon Sneed on 8/9/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

internal enum SemverPart: Int {
    case breaking
    case feature
    case fix
    
    case major
    case minor
    case patch
    
    case primaryPartial
    case secondaryPartial
    
    case leftMostNonZero
    case rightMostNonZero
}

// MARK: Semver Public interface

public struct Semver {
    public fileprivate(set) var prefix: String? = nil
    
    public fileprivate(set) var breaking: Int
    public fileprivate(set) var feature: Int
    public fileprivate(set) var fix: Int
    
    public var major: Int {
        return breaking
    }
    
    public var minor: Int {
        return feature
    }
    
    public var patch: Int {
        return fix
    }
    
    public fileprivate(set) var preRelease: String? = nil
    public fileprivate(set) var build: String? = nil
    
    public fileprivate(set) var valid = true
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
            return "\(prefix ?? "")\(breaking).\(feature).\(fix)-\(pre).\(preReleaseVersionData.map(String.init).joined(separator: "."))"
        } else {
            return "\(prefix ?? "")\(breaking).\(feature).\(fix)"
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

extension String {
    func matchesForRegex(_ regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range) }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: Internal stuff

internal enum SemverComparison {
    case equal
    case greaterThan
    case lessThan
    case unknown
}

extension Semver {
    fileprivate mutating func parse(_ value: String) {
        
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
            let versionComponents = versionMatches[0].components(separatedBy: ".")
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
                // now remove any versions after the prerelease tag.
                if let firstDot = preRelease!.characters.index(of: ".") {
                    preRelease = preRelease!.substring(to: firstDot)
                }
            }
            
            if buildMatches.count > 0 {
                // remove the leading +, it *will* be there due to the regex.
                build = String(buildMatches[0].characters.dropFirst())
            }
            
        } else {
            // we didn't have any version matches, maybe it's got x-ranges in it.
            if xMatches.count > 0 {
                for (index, element) in xMatches.enumerated() {
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
    
    fileprivate func prefix(_ value: String) -> String? {
        let prefix = value.matchesForRegex(PrefixRegex)
        
        if prefix.count == 1 {
            return prefix[0]
        }
        
        return nil
    }
    
    fileprivate func clean(_ value: String) -> String {
        let cleanMatches = value.matchesForRegex(CleanRegex)
        
        if cleanMatches.count == 1 {
            return cleanMatches[0]
        }
        
        return ""
    }
    
    fileprivate func elements() -> [Int] {
        var items = [Int]()
        
        items.append(breaking)
        items.append(feature)
        items.append(fix)
        
        preReleaseVersionData.forEach { (value) in
            items.append(value)
        }
        
        return items
    }
    
    fileprivate func comparison(_ ver: Semver) -> SemverComparison {
        var result = SemverComparison.unknown
        
        let this = elements()
        let that = ver.elements()
        
        if this == that {
            return .equal
        }
        
        for (index, element) in this.enumerated() {
            if index < that.count {
                let thatElement = that[index]
                if element > thatElement {
                    result = .greaterThan
                    break
                }
                if element < thatElement {
                    result = .lessThan
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
    
    internal mutating func increment(_ part: SemverPart) {
        switch part {
        case .major:
            fallthrough
        case .breaking:
            breaking += 1
            feature = 0
            fix = 0
            
        case .minor:
            fallthrough
        case .feature:
            feature += 1
            fix = 0
            
        case .patch:
            fallthrough
        case .fix:
            fix += 1
           
        // increment the first partial we come across as if it were the 1st in a range
        case .primaryPartial:
            if breaking == -1 {
                breaking = 0
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
        case .secondaryPartial:
            if breaking == -1 {
                breaking = 1
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
            
        case .leftMostNonZero:
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
                    partsOut.append(0)
                }
            }
            
            breaking = partsOut[0]
            feature = partsOut[1]
            fix = partsOut[2]
            
            // everything was zero's, so increment feature.
            if gotFirst == false {
                feature += 1
            }
            
        case .rightMostNonZero:
            var parts = [breaking, feature, fix]
            var partsOut = [Int]()
            var gotFirst = false
            
            // we're doing right-most
            parts = parts.reversed()
            
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
            
            // flip the output back around
            partsOut = partsOut.reversed()
            
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

extension Semver: Equatable, Comparable { }

public func ==(lhs: Semver, rhs: Semver) -> Bool {
    return lhs.comparison(rhs) == .equal
}

public func >(lhs: Semver, rhs: Semver) -> Bool {
    return lhs.comparison(rhs) == .greaterThan
}

public func <(lhs: Semver, rhs: Semver) -> Bool {
    return lhs.comparison(rhs) == .lessThan
}

public func >=(lhs: Semver, rhs: Semver) -> Bool {
    let result = lhs.comparison(rhs)
    return result == .equal || result == .greaterThan
}

public func <=(lhs: Semver, rhs: Semver) -> Bool {
    let result = lhs.comparison(rhs)
    return result == .equal || result == .lessThan
}

// MARK: SemverComparator enum

internal enum SemverComparator: CustomStringConvertible, Equatable, Hashable {
    case greaterThan(version: Semver)
    case lessThan(version: Semver)
    case greaterThanOrEqual(version: Semver)
    case lessThanOrEqual(version: Semver)
    case exactMatch(version: Semver)
    case logicalOr
    
    static func basicComparator(string: String) -> SemverComparator {
        let rangeTokens = [Token.LessThan.rawValue,
                           Token.GreaterThan.rawValue,
                           Token.LessThanOrEqual.rawValue,
                           Token.GreaterThanOrEqual.rawValue]
        
        var v = Semver(string.stringByRemovingAll(rangeTokens))
        v.normalize()

        if string.contains(">=") {
            return .greaterThanOrEqual(version: v)
        } else if string.contains(">") {
            return .greaterThan(version: v)
        } else if string.contains("<=") {
            return .lessThanOrEqual(version: v)
        } else if string.contains("<") {
            return .lessThan(version: v)
        } else if string.contains("||") {
            return .logicalOr
        }
        return .exactMatch(version: v)
    }
    
    var description: String {
        switch self {
        case .greaterThan(let version):
            return ">\(version.stringValue)"
            
        case .lessThan(let version):
            return "<\(version.stringValue)"
            
        case .greaterThanOrEqual(let version):
            return ">=\(version.stringValue)"
            
        case .lessThanOrEqual(let version):
            return "<=\(version.stringValue)"
            
        case .exactMatch(let version):
            return "\(version.stringValue)"
            
        case .logicalOr:
            return "||"
        }
    }
    
    var version: Semver? {
        switch self {
        case .greaterThan(let version):
            return version
            
        case .lessThan(let version):
            return version
            
        case .greaterThanOrEqual(let version):
            return version
            
        case .lessThanOrEqual(let version):
            return version
            
        case .exactMatch(let version):
            return version
            
        case .logicalOr:
            return nil
        }
    }
    
    var hashValue: Int {
        return description.hashValue
    }
    
    static func ==(lhs: SemverComparator, rhs: SemverComparator) -> Bool {
        return lhs.hashValue == rhs.hashValue
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
    case Space = " "
}

public struct SemverRange {
    public fileprivate(set) var valid = true
    
    internal var comparators = [SemverComparator]()
    
    public init(_ value: String) {
        original = value
        
        parse()
    }
    
    fileprivate mutating func parse() {
        // remove the spaces around the dash to prevent conflicts
        //let trimmedOriginal = original.replace(" - ", replacement: "-")
        
        let parts = original.components(separatedBy: "||")
        let set = parts.map { (section) -> String in
            let result = section.clean()
            return result
        }
        
        comparators = transmogrify(set)
    }
    
    fileprivate mutating func transmogrify(_ set: [String]) -> [SemverComparator] {
        var resultSet = [SemverComparator]()
        
        let rangeTokens = [Token.LessThanOrEqual.rawValue,
                           Token.GreaterThanOrEqual.rawValue,
                           Token.LessThan.rawValue,
                           Token.GreaterThan.rawValue,
                           Token.Caret.rawValue,
                           Token.Tilde.rawValue,
                           Token.Dash.rawValue,
                           Token.Space.rawValue]
        
        // look for the range marker ' - '
        for item in set {
            if item.containsString(Token.Dash.rawValue) {
                // -
                // now we need to split it in two.
                let pieces = item.components(separatedBy: Token.Dash.rawValue).map { (piece) -> String in
                    return piece.stringByRemovingAll(rangeTokens)
                }
                
                if pieces.count == 2 {
                    var ver1 = Semver(pieces[0])
                    var ver2 = Semver(pieces[1])
                    
                    // if we have a partial version, bump it accordingly
                    if ver1.partial {
                        ver1.increment(.primaryPartial)
                    }
                    // we add it the same way, whether it's partial or not.
                    resultSet.append(.greaterThanOrEqual(version: ver1))
                    
                    if ver2.partial {
                        ver2.increment(.secondaryPartial)
                        resultSet.append(.lessThan(version: ver2))
                    } else {
                        resultSet.append(.lessThanOrEqual(version: ver2))
                    }
                }
            } else if item.containsString(Token.Space.rawValue) {
                // space
                // now we need to split it in two.
                let pieces = item.components(separatedBy: Token.Space.rawValue)
                if pieces.count == 2 {
                    resultSet.append(SemverComparator.basicComparator(string: pieces[0]))
                    resultSet.append(SemverComparator.basicComparator(string: pieces[1]))
                }
            }  else if item.containsString(Token.Tilde.rawValue) {
                // ~
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                var ver2 = Semver(piece)
                
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.greaterThanOrEqual(version: ver1))
                
                if ver2.partial {
                    ver2.increment(.secondaryPartial)
                } else {
                    ver2.increment(.feature)
                }
                resultSet.append(.lessThan(version: ver2))
            } else if item.containsString(Token.Caret.rawValue) {
                // ^
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                var ver2 = Semver(piece)
                
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.greaterThanOrEqual(version: ver1))
                
                if ver2.partial {
                    ver2.normalize()
                }
                ver2.increment(.leftMostNonZero)
                resultSet.append(.lessThan(version: ver2))
            } else if item.containsString(Token.LessThanOrEqual.rawValue) {
                // <=
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.lessThanOrEqual(version: ver1))
            } else if item.containsString(Token.GreaterThanOrEqual.rawValue) {
                // >=
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.greaterThanOrEqual(version: ver1))
            } else if item.containsString(Token.LessThan.rawValue) {
                // <
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.lessThan(version: ver1))
            } else if item.containsString(Token.GreaterThan.rawValue) {
                // >
                let piece = item.stringByRemovingAll(rangeTokens)
                var ver1 = Semver(piece)
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.greaterThan(version: ver1))
            } else if item.contains("*") || item.contains("x") || item.contains("X") {
                // *, x, X
                let piece = item
                var ver1 = Semver(piece)
                var ver2 = Semver(piece)
                
                if ver1.partial {
                    ver1.normalize()
                }
                resultSet.append(.greaterThanOrEqual(version: ver1))
                
                if ver2.partial {
                    ver2.normalize()
                    ver2.increment(.leftMostNonZero)
                    resultSet.append(.lessThan(version: ver2))
                }
            } else {
                let exactVersion = Semver(item)
                
                if exactVersion.valid {
                    resultSet.append(.exactMatch(version: exactVersion))
                } else {
                    // it doesn't match anything.
                    valid = false
                }
                break
            }
            
            resultSet.append(.logicalOr)
        }
        
        return resultSet
    }

    internal var simplified = [String]()
    internal let original: String
    
}

// MARK: Range matching

extension Semver {
    
    public func satisfies(_ range: SemverRange) -> Bool {
        var overallResult = false
        
        // we can only ever have a maximum of 2 comparators, but as little as 1.
        var firstResult: Bool? = nil
        var secondResult: Bool? = nil
        
        let comps = range.comparators
        print(comps)
        for ver in comps {
            print("\(self.stringValue) == \(ver)?")
            
            var verResult = false
            
            switch ver {
            case .greaterThan(let version):
                verResult = self > version
                
            case .lessThan(let version):
                verResult = self < version
                
            case .greaterThanOrEqual(let version):
                verResult = self >= version
                
            case .lessThanOrEqual(let version):
                verResult = self <= version
                
            case .exactMatch(let version):
                verResult = self == version
                overallResult = verResult
                
            case .logicalOr:
                break
            }
            
            if ver == SemverComparator.logicalOr {
                overallResult = (firstResult! == true) && (secondResult != nil ? secondResult! : true)
            }
            
            if verResult {
                let preMatch = comparePreReleaseOnly(comparator: ver)
                if preMatch {
                    firstResult = true
                    secondResult = true
                    overallResult = true
                    break
                } else {
                    if preRelease != nil {
                        verResult = false
                    }
                }
            }
            
            if overallResult == true {
                break
            }

            if firstResult == nil {
                firstResult = verResult
            } else {
                secondResult = verResult
            }
        }
        
        return overallResult
    }
    
    private func comparePreReleaseOnly(comparator: SemverComparator) -> Bool {
        var result = false
        guard let version = comparator.version else { return result }
        
        if version.preRelease == nil || preRelease == nil {
            return result
        } else {
            let versionMatch = (version.breaking == breaking && version.feature == feature && version.fix == fix)
            let preMatch = (version.preRelease != nil && preRelease != nil && version.preRelease == preRelease)

            if versionMatch && preMatch {
                result = true
            } else {
                result = false
            }
        }
        
        return result
    }
    
}


extension SemverRange {
    public func compatible(versions: [Semver]) -> [Semver] {
        var result = [Semver]()
        
        for ver in versions {
            if ver.satisfies(self) {
                result.append(ver)
            }
        }
        
        return result
    }
    
    public func mostUpToDate(versions: [Semver]) -> Semver? {
        let compat = compatible(versions: versions)
        
        if compat.count == 0 {
            return nil
        }
        
        let result = compat.max()
        return result
    }
}

