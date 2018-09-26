//
//  DefaultsCommand.swift
//  ModuloKit
//
//  Created by Daniel Miedema on 9/25/18.
//  Copyright © 2018 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
#endif

open class DefaultsCommand: NSObject, Command {
    // Internal Properties
    fileprivate var toggleVerbose: Bool = false
    fileprivate var verboseValue: String? = nil
    fileprivate var moduleFolderPath: String? = nil
    fileprivate var setValue: Bool = false

    // Protocol Conformance
    public var name: String { return "defaults" }

    public var shortHelpDescription: String {
        return "Set default arguments/configuration properties for this repository"
    }

    public var longHelpDescription: String {
        return """
        Set default argument values for all commands to be run.
        This will make changes to the `.modulo` file reflecting the
        new defaults that have been set
        """
    }

    public var failOnUnrecognizedOptions: Bool { return true }

    public var verbose: Bool = State.instance.options.verbose
    public var quiet: Bool = false

    public func execute(_ otherParams: Array<String>?) -> Int {
        guard var spec = ModuleSpec.workingSpec() else {
            exit(ErrorCode.notInitialized)
            return ErrorCode.notInitialized.rawValue
        }

        if setValue {
            if toggleVerbose {
                let newValue: Bool
                switch verboseValue {
                case "true":
                    newValue = true
                case "false":
                    newValue = false
                default:
                    writeln(.stderr, "\(verboseValue ?? "") is not `true` or `false`. Interpretting as `false`.")
                    newValue = false
                }

                spec.options.verbose = newValue
                State.instance.options.verbose = newValue
            }
            if let moduleFolderPath = moduleFolderPath,
                !moduleFolderPath.isEmpty {
                spec.options.depdencyInstallationPath = moduleFolderPath
                State.instance.options.depdencyInstallationPath = moduleFolderPath
            }
            spec.save()
        } else {
            if toggleVerbose {
                writeln(.stdout, "Verbose - \(spec.options.verbose)")
            }
            if moduleFolderPath != nil {
                writeln(.stdout, "depdencyInstallationPath - \(spec.options.depdencyInstallationPath)")
            }

        }

        return ErrorCode.success.rawValue
    }

    open func configureOptions() {
        addOption(["--set"], usage: "set a new value for the given") { (option, value) in
            self.setValue = true
        }

        addOptionValue(["--verboseOutput"],
            usage: "specify `verbose` for all commands that are run",
            valueSignature: "<[true|false}>") { (option, value) in
            self.toggleVerbose = true
            self.verboseValue = value
        }

        addOptionValue(["--moduleFolder"],
           usage: "specify the desired dependency path",
           valueSignature: "<path>") { (option, value) in
            self.moduleFolderPath = value ?? ""
        }
    }
}
