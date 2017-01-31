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
    case success = 0
    case unknownError
    case commandError
    case specNotFound
    case specNotWritable
    case scmNotFound
    case scmNotInitialized
    case alreadyInitialized
    case notInitialized
    case noMatchingDependencies
    case dependencyAlreadyExists
    case dependencyUnclean
    case dependencyUnknown
    
    var description: String {
        var result: String = ""
        switch self {
        case .success:
            break
        case .unknownError:
            result = "An unknown error occurred."
        case .commandError:
            result = "There was an error in the command line used."
        case .specNotFound:
            result = ".modulo file not found."
        case .specNotWritable:
            result = ".modulo cannot be written to, check permissions."
        case .scmNotFound:
            result = "No supported SCM was found."
        case .scmNotInitialized:
            result = "An SCM has not been initialized in this directory."
        case .alreadyInitialized:
            result = "Modulo has already been initialized."
        case .notInitialized:
            result = "Modulo has not been initialized."
        case .noMatchingDependencies:
            result = "No matching dependencies were found."
        case .dependencyAlreadyExists:
            result = "The dependency already exists."
        case .dependencyUnclean:
            result = "The dependency is not clean."
        case .dependencyUnknown:
            result = "The specified dependency is unknown."
        }
        return result
    }
}

internal func exit(_ code: ErrorCode, closure: (() -> Void)? = nil) {
    if code != .success {
        writeln(.stderr, code.description)
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

