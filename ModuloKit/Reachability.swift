//
//  Reachability.swift
//  modulo
//
//  Created by Sneed, Brandon on 7/10/17.
//  Copyright © 2017 TheHolyGrail. All rights reserved.
//

import Foundation
import SystemConfiguration

func canConnect(hostname: String) -> Bool {
    guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else {
        return false
    }
    
    var flags = SCNetworkReachabilityFlags()
    let gotFlags = SCNetworkReachabilityGetFlags(ref, &flags)
    
    let result = gotFlags && flags.contains(.reachable) && !flags.contains(.connectionRequired)
    
    return result
}

/*func internetIsReachable() -> Bool {
    var zeroAddress = sockaddr()
    zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
    zeroAddress.sa_family = sa_family_t(AF_INET)
    
    guard let ref: SCNetworkReachability = withUnsafePointer(to: &zeroAddress, {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
        return false
    }

    var reachabilityFlags = SCNetworkReachabilityFlags()
    let flags = withUnsafeMutablePointer(to: &reachabilityFlags) {
        SCNetworkReachabilityGetFlags(ref, UnsafeMutablePointer($0))
    }
    
    /*
    guard isReachableFlagSet else { return false }
    
    if isConnectionRequiredAndTransientFlagSet {
        return false
    }
    
    if isRunningOnDevice {
        if isOnWWANFlagSet && !reachableOnWWAN {
            // We don't want to connect when on 3G.
            return false
        }
    }
    
    return true
    */

    
    let reachable = reachabilityFlags.contains(.reachable)
    let connRequired = reachabilityFlags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    
}*/
