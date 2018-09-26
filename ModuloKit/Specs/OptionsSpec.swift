//
//  OptionsSpec.swift
//  ModuloKit
//
//  Created by Daniel Miedema on 9/25/18.
//  Copyright © 2018 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCodable
#endif

public struct OptionsSpec {
    /// Should we have `verbose` on all commands
    var verboseOutput: Bool = false
    /// Path to store our 'modules'/dependencies in
    var depdencyInstallationPath: String = "modules"
}

extension OptionsSpec: ELDecodable {
    public static func decode(_ json: JSON?) throws -> OptionsSpec {
        return try OptionsSpec(
            verboseOutput: json ==> "verboseOutput",
            depdencyInstallationPath: json ==> "depdencyInstallationPath"
        )
    }
}

extension OptionsSpec: ELEncodable {
    public func encode() throws -> JSON {
        return try encodeToJSON([
            "verboseOutput" <== verboseOutput,
            "depdencyInstallationPath" <== depdencyInstallationPath
        ])
    }
}
