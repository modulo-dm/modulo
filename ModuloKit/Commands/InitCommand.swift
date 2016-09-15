//
//  InitCommand.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/16/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
#endif

public class InitCommand: NSObject, Command {
    // Internal properties
    public var isModule: Bool = true
    
    // Protocol conformance
    public var name: String { return "init" }
    public var shortHelpDescription: String { return "Initialize modulo"  }
    public var longHelpDescription: String {
        return "This command initializes modulo and creates a .modulo file\n" +
               "containing module dependency information."
    }
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var verbose: Bool = false
    public var quiet: Bool = false
    
    public func configureOptions() {
        addOption(["--app"], usage: "init's the working path as an application") { (option, value) in
            self.isModule = false
        }
        
        addOption(["--module"], usage: "init's the working path as a module (default)") { (option, value) in
            self.isModule = true
        }
    }
    
    public func execute(otherParams: Array<String>?) -> Int {
        let scm = currentSCM()
        
        if ModuleSpec.exists() {
            exit(.AlreadyInitialized)
        }
        
        if isModule == false {
            let scmResult = scm.addModulesIgnore()
            if scmResult != .Success {
                exit(scmResult.errorMessage())
            }
        }
        
        let specPath = NSFileManager.workingPath().appendPathComponent(specFilename)
        let spec = ModuleSpec(name: NSFileManager.directoryName(), module: isModule, sourcePath: nil, dependencies: [], path: specPath)
        let success = spec.save()
        
        if !success {
            exit(ErrorCode.SpecNotWritable)
        } else {
            writeln(.Stdout, "Modulo has been initialized.")
        }
        
        return ErrorCode.Success.rawValue
    }
}
