//
//  SemverCodable.swift
//  modulo
//
//  Created by Sneed, Brandon on 6/1/17.
//  Copyright © 2017 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCodable
#endif

extension SemverRange: Encodable {
    public func encode() throws -> JSON {
        if self.valid {
            return JSON(self.original)
        } else {
            throw EncodeError.unencodable
        }
    }
}

extension SemverRange: Decodable {
    public static func decode(_ json: JSON?) throws -> SemverRange {
        if let value = json?.string {
            let range = SemverRange(value)
            if range.valid {
                return range
            }
        }

        throw DecodeError.undecodable
    }
}
