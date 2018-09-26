//
//  Modulo.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/15/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
    import ELCLI
    import ELFoundation
#endif

@objc
open class Modulo: NSObject {

    public static func run() {
        let error = run([])
        exit(Int32(error.rawValue))
    }

    public static func run(_ args: [String]) -> ErrorCode {
        let cli = CLI(name: "modulo", version: "0.7.0", description: "A simple dependency manager")

        // before we do anything make sure our options are applied to our
        // current state. If we don't have a working spec the defaults will do fine
        if let options = ModuleSpec.workingSpec()?.options {
            State.instance.options = options
        }

        if args.count > 0 {
            cli.allArgumentsToExecutable = args
        }

        cli.addCommands([InitCommand(), AddCommand(), UpdateCommand(), StatusCommand(), MapCommand(), SetCommand(), DefaultsCommand()])

        if let error = ErrorCode(rawValue: cli.run()) {
            if error == .success {
                State.instance.showFinalInformation()
            }

            return error
        }

        return ErrorCode.unknownError
    }
}
