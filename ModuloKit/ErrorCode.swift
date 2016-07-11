//
//  ErrorCodes.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/16/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
    import ELFoundation
#endif

public enum ErrorCode: Int {
    case Success = 0
    case UnknownError = 1
    case CommandError = 2
    case SpecNotFound = 3
    case SpecNotWritable = 4
    case NoSCMFoundOrInitialized = 5
    case AlreadyInitialized = 6
    case NotInitialized = 7
    case NoMatchingDependencies = 8
    case DependencyAlreadyExists = 9
    
    var description: String {
        var result: String = ""
        switch self {
        case .Success:
            break
        case .UnknownError:
            result = "An unknown error occurred."
        case .CommandError:
            result = "There was an error in the command line used."
        case .SpecNotFound:
            result = ".modulo file not found."
        case .SpecNotWritable:
            result = ".modulo cannot be written to, check permissions."
        case .NoSCMFoundOrInitialized:
            result = "No supported SCM was found to be initialized."
        case .AlreadyInitialized:
            result = "Modulo has already been initialized."
        case .NotInitialized:
            result = "Modulo has not been initialized."
        case .NoMatchingDependencies:
            result = "No matching dependencies were found."
        case .DependencyAlreadyExists:
            result = "The dependency already exists."
        }
        return result
    }
}

internal func exit(code: ErrorCode, closure: (() -> Void)? = nil) {
    if code != .Success {
        writeln(.Stderr, code.description)
    }
    
    if let closure = closure {
        closure()
    }
    
    if isInUnitTest() {
        exceptionFailure(code.description)
    } else {
        exit(Int32(code.rawValue))
    }
}

