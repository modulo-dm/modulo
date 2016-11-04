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
    case unknownError = 1
    case commandError = 2
    case specNotFound = 3
    case specNotWritable = 4
    case noSCMFoundOrInitialized = 5
    case alreadyInitialized = 6
    case notInitialized = 7
    case noMatchingDependencies = 8
    case dependencyAlreadyExists = 9
    case dependencyUnclean = 10
    
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
        case .noSCMFoundOrInitialized:
            result = "No supported SCM was found to be initialized."
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

