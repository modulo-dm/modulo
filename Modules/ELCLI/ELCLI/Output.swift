//
//  Output.swift
//  ELCLI
//
//  Created by Brandon Sneed on 8/13/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
import ELFoundation
#endif

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

public enum Output {
    case stdin
    case stdout
    case stderr
    
    func fileHandle() -> FileHandle {
        switch self {
        case .stdin:
            return FileHandle.standardInput
        case .stderr:
            return FileHandle.standardError
        case .stdout:
            fallthrough
        default:
            return FileHandle.standardOutput
        }
    }
}

public func write(_ destination: Output, _ data: String) {
    var str = data
    var finalDestination = destination
    if destination == .stderr {
        str = "error: " + data
        if isInUnitTest() {
            // if we're debugging unit tests, data won't show if it's spit otu to stderr.
            finalDestination = .stdout
        }
    }

    if let outputData = str.data(using: String.Encoding.utf8) {
        finalDestination.fileHandle().write(outputData)
    }
}

public func writeln(_ destination: Output, _ data: String) {
    write(destination, data + "\n")
}

public func exitSuccess() {
    if isInUnitTest() {
        exceptionFailure("")
    } else {
        exit(0)
    }
}

public func exit(_ data: String, closure: (() -> Void)? = nil) {
    writeln(.stderr, data)
    if let closure = closure {
        closure()
    }
    
    if isInUnitTest() {
        exceptionFailure(data)
    } else {
        exit(1)
    }
}

public func printOption(_ option: Option) {
    if option.flags == nil || option.valueSignatures?.count > 1 {
        return
    }
    
    var flagData = "     "
    
    if let flags = option.flags {
        for index in 0..<flags.count {
            if index == 0 {
                flagData += flags[index]
            } else {
                flagData += ", " + flags[index]
            }
        }
    }
    
    if let sigs = option.valueSignatures {
        if sigs.count > 0 {
            flagData += " " + sigs[0]
        }
    }
    
    flagData = flagData.padBack(26)
    
    let usageData = option.usage!
    
    if flagData.characters.count > 26 {
        flagData += "\n"
        flagData += usageData.padFront(27 + usageData.characters.count)
    } else {
        flagData += " " + usageData
    }
    
    writeln(.stdout, flagData)
    
}

public func printCommand(_ command: Command) {
    if command.name.hasPrefix("-") {
        return
    }
    
    var commandData = "   "
    
    commandData += command.name.padBack(14)
    commandData += " " + command.shortHelpDescription
    
    writeln(.stdout, commandData)
}
