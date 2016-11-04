//
//  NSBundle.swift
//  THGDispatch
//
//  Created by Brandon Sneed on 2/16/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

public extension Bundle {
    /**
     Returns the reverse DNS style bundle identifier

     - returns: The reverse DNS style bundle identifier
    
     Example: com.walmartlabs.thgfoundation
    */
    public func reverseBundleIdentifier() -> String? {
        if let id = bundleIdentifier {
            let components: [String] = id.components(separatedBy: ".")
            let reverseComponents = Array(components.reversed())
            let result = reverseComponents.joined(separator: ".")
            return result
        }
        
        return nil
    }
}
