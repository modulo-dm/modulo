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
    var repositoryURL: String
    // version or version range
    var version: SemverRange?
    // tells modulo the dependency is unmanaged
    var unmanaged: Bool? = true
}

extension DependencySpec: Decodable {
    public static func decode(_ json: JSON?) throws -> DependencySpec {
        return try DependencySpec(
            repositoryURL: json ==> "repositoryURL",
            version: json ==> "version",
            unmanaged: json ==> "unmanaged"
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
            "version" <== version,
            "unmanaged" <== unmanaged
        ])
    }
}

extension DependencySpec {
    public func name() -> String {
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


