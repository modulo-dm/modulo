//
//  Command.swift
//  ELCLI
//
//  Created by Brandon Sneed on 7/27/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

#if NOFRAMEWORKS
#else
import ELFoundation
#endif

public protocol Command: AnyObject {
    // descriptive properties
    var name: String { get }
    var shortHelpDescription: String { get }
    var longHelpDescription: String { get }
    var failOnUnrecognizedOptions: Bool { get }
    
    // global command properties
    var verbose: Bool { get set }
    var quiet: Bool { get set }
    
    func configureOptions()
    func execute(_ otherParams: Array<String>?) -> Int
}

private var optionArrayKey: NSString = "ELCLIOptionsKey"

public extension Command {
    public var options: Array<Option> {
        get {
            var optionArray: Array<Option>? = getAssociatedObject(self, associativeKey: &optionArrayKey)
            if optionArray == nil {
                let newArray = Array<Option>()
                setAssociatedObject(self, value: newArray, associativeKey: &optionArrayKey, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                optionArray = newArray
            }
            return optionArray!
        }
    }
    
    public func addOption(_ flags: Array<String>, usage: String, closure: @escaping OptionClosure) {
        addOption(flags, usage: usage, valueSignatures: nil, closure: closure)
    }

    public func addOptionValue(_ flags: Array<String>, usage: String, valueSignature: String, closure: @escaping OptionClosure) {
        addOption(flags, usage: usage, valueSignatures: [valueSignature], closure: closure)
    }
    
    public func addFlaglessOptionValues(_ valueSignatures: Array<String>, closure: @escaping OptionClosure) {
        addOption(nil, usage: nil, valueSignatures: valueSignatures, closure: closure)
    }
    
    public func showHelp() {
        write(.stdout, "usage: ")
        write(.stdout, "\(ProcessInfo.processInfo.processName) ")
        write(.stdout, "\(name) [options] ")
        
        let options = self.options
        
        // find any flagless value signature so we can display them since they're non-optional.
        var flagless = options.filter { (option) -> Bool in
            if option.flags == nil && option.valueSignatures != nil {
                return true
            }
            return false
        }
        
        if flagless.count > 0, let signatures = flagless[0].valueSignatures {
            for index in 0..<signatures.count {
                write(.stdout, signatures[index] + " ")
            }
        }
        
        writeln(.stdout, "\n")

        // print global options here.
        
        // print long help description here.
        writeln(.stdout, self.longHelpDescription)
        writeln(.stdout, "")

        // print command specific options here.
        
        var flags = options.filter { (option) -> Bool in
            if option.flags != nil {
                return true
            }
            return false
        }
        
        if flags.count > 0 {
            for index in 0..<flags.count {
                printOption(flags[index])
            }
        }
        
        writeln(.stdout, "")
        
    }

    fileprivate func addOption(_ flags: Array<String>?, usage: String?, valueSignatures: Array<String>?, closure: @escaping OptionClosure) {
        let option = Option(flags: flags, usage: usage, valueSignatures: valueSignatures, closure: closure)
        var optionArray = self.options
        
        optionArray.append(option)
        
        // we have to set it again because Swift Array's are structs and the mutability gets lost in the various set's.
        setAssociatedObject(self, value: optionArray, associativeKey: &optionArrayKey, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func addGlobalCommandOptions() {
        addOption(["--help"], usage: "show help for this command") { (option, value) -> Void in
            self.showHelp()
            exitSuccess()
        }
        
        addOption(["-v", "--verbose"], usage: "be verbose") { (option, value) -> Void in
            self.verbose = true
        }
    }
}


