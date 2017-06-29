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

open class InitCommand: NSObject, Command {
    // Internal properties
    open var isModule: Bool = false
  
    // Protocol conformance
    open var name: String { return "init" }
    open var shortHelpDescription: String { return "Initialize modulo"  }
    open var longHelpDescription: String {
        return "This command initializes modulo and creates a .modulo file\n" +
               "containing module dependency information."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = false
    open var quiet: Bool = false
    
    open func configureOptions() {
        addOption(["--app"], usage: "init's the working path as an application (default)") { (option, value) in
            self.isModule = false
        }
        
        addOption(["--module"], usage: "init's the working path as a module") { (option, value) in
            self.isModule = true
        }
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        //let scm = currentSCM()
        let workingPath = FileManager.workingPath()

        // Already nested in a Modules/ directory? Init as a module.
        if isValidModuleDirectory(path: workingPath) {
            isModule = true
            writeln(.stdout, "Initializing as a module, since you're already in the Modules directory ...")
        }

        if ModuleSpec.exists() {
            exit(.alreadyInitialized)
        }
      
        let specPath = workingPath.appendPathComponent(specFilename)
        let spec = ModuleSpec(name: FileManager.directoryName(), module: isModule, sourcePath: nil, dependencies: [], path: specPath)
        let success = spec.save()
        
        if !success {
            exit(ErrorCode.specNotWritable)
        } else {
            writeln(.stdout, "Modulo has been initialized.")
        }
        
        return ErrorCode.success.rawValue
    }
  
    open func isValidModuleDirectory(path: String) -> Bool {
      let relativeParentPath = path.appendPathComponent("..")
      let absolutePath = NSString(string: relativeParentPath).standardizingPath // normalizes relative path segments
      let parentDirectoryName = NSString(string: absolutePath).lastPathComponent
      
      return parentDirectoryName == State.instance.modulePathName
    }
}
