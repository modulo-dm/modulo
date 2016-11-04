//
//  String.swift
//  ELFoundation
//
//  Created by Brandon Sneed on 3/16/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

public extension String {
    /**
     Returns a GUID in the form of "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX".

     - returns: A unique string identifier.
    */
    static public func GUID() -> String {
        return UUID().uuidString
    }
    
}
