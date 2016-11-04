//
//  NSURL.swift
//  ELFoundation
//
//  Created by Brandon Sneed on 4/15/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import Foundation

public extension URL {
    /**
    Breaks down a query string (ie: "") into it's decoded parts.
    */
    public var queryDictionary: [String: String]? {
        if let queryString = query {
            var result = [String: String]()
            
            let components = queryString.components(separatedBy: "&")
            for item in components {
                let pair = item.components(separatedBy: "=")
                let key = pair[0]
                let value = pair[1]
                
                let decodedKey = key.removingPercentEncoding
                let decodedValue = value.removingPercentEncoding
                
                // if we can't get non-optionals, it's unable to be decoded.
                if let key = decodedKey, let value = decodedValue {
                    result[key] = value
                }
            }
            
            if result.count > 0 {
                return result
            }
        }
        // if we didn't return prior to this, send back nil.
        return nil
    }
}
