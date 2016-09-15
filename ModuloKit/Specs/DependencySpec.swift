//
//  DependencySpec.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/16/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCodable
#endif

public struct DependencySpec {
    // repository url to fetch the dep from
    let repositoryURL: String
    // can be a branch, commit, or tag
    let checkout: String
    // if this has a value, don't allow updates
    let redirectURL: String?
}

extension DependencySpec: Decodable {
    public static func decode(json: JSON?) throws -> DependencySpec {
        return try DependencySpec(
            repositoryURL: json ==> "repositoryURL",
            checkout: json ==> "checkout",
            redirectURL: json ==> "redirectURL"
        )
    }
    
    public func validate() throws -> DependencySpec {
        return self
    }
}

extension DependencySpec: Encodable {
    public func encode() throws -> JSON {
        return try encodeToJSON([
            "repositoryURL" <== repositoryURL,
            "checkout" <== checkout,
            "redirectURL" <== redirectURL
        ])
    }
}

extension DependencySpec {
    func name() -> String {
        return repositoryURL.nameFromRemoteURL()
    }
}

extension DependencySpec: Hashable {
    public var hashValue: Int {
        return repositoryURL.hashValue
    }
}

public func ==(lhs: DependencySpec, rhs: DependencySpec) -> Bool {
    return lhs.repositoryURL == rhs.repositoryURL
}



