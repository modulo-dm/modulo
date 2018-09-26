//
//  MapCommand.swift
//  modulo
//
//  Created by Sneed, Brandon on 1/21/17.
//  Copyright © 2017 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
#endif

open class MapCommand: NSObject, Command {
    // Protocol conformance
    open var name: String { return "map" }
    open var shortHelpDescription: String { return "Displays information about dependencies"  }
    open var longHelpDescription: String {
        return "Displays information about this project's dependencies."
    }
    open var failOnUnrecognizedOptions: Bool { return true }
    
    open var verbose: Bool = State.instance.options.verbose
    open var quiet: Bool = false
    
    fileprivate var simple = false
    
    open func configureOptions() {
        addOption(["-s", "--simple"], usage: "shows a simple dependency map") { (option, value) in
            self.simple = true
        }
    }
    
    open func execute(_ otherParams: Array<String>?) -> Int {
        guard let spec = ModuleSpec.workingSpec() else {
            exit(ErrorCode.notInitialized)
            return -1
        }
        
        writeln(.stdout, "Dependencies for `\(spec.name)`: ")

        let deps = spec.allDependencies()
        
        if (simple) {
            for dep in deps {
                let users = whatDependsOn(dep, outOf: deps)
                printMap(dep: dep, explicit: spec.dependencies.contains(dep), users: users)
            }
        } else {
            for (index, dep) in spec.dependencies.enumerated() {
                printMapVisualAccuracy(mainSpec: spec, depth: 0, index: index, count: spec.dependencies.count, dep: dep, allDependencies: deps)
            }
        }
        
        return 0
    }
    
    func printMap(dep: DependencySpec, explicit: Bool, users: [DependencySpec]) {
        
        let names: [String] = users.map { (item) -> String in
            return item.name()
        }
        
        let usedBy = names.joined(separator: ", ")
        
        writeln(.stdout, "  name    : \(dep.name())")
        writeln(.stdout, "  explicit: \(explicit)")
        if users.count > 0 {
            writeln(.stdout, "  used by : \(usedBy)")
        }
        
        writeln(.stdout, "")
    }
    
    func printMapReadable(mainSpec: ModuleSpec, depth: UInt, index:Int, count: Int, dep: DependencySpec, allDependencies: [DependencySpec]) {
        let users = whatDependsOn(dep, outOf: allDependencies)
        
        let names: [String] = users.map { (item) -> String in
            return item.name()
        }
        
        let usedBy = names.joined(separator: ", ")
        
        let explicit = mainSpec.dependencies.contains(dep)
        let padStr = "  "
        
        let startChar = "├─"
        let lineChar = "│"
        
        var pad = padStr + lineChar
        for _ in 0..<depth {
            pad = padStr + lineChar + pad
        }
        
        let namePadRange = pad.range(of: lineChar, options: .backwards, range: nil, locale: nil)
        let namePad = pad.replacingOccurrences(of: lineChar, with: startChar, options: .anchored, range: namePadRange)
        
        writeln(.stdout, "\(pad)")
        writeln(.stdout, "\(namePad) name    : \(dep.name())")
        
        writeln(.stdout, "\(pad)  explicit: \(explicit)")
        if users.count > 0 {
            writeln(.stdout, "\(pad)  used by : \(usedBy)")
        }
        
        if let spec = ModuleSpec.load(dep) {
            for (indx, subDep) in spec.dependencies.enumerated() {
                printMapReadable(mainSpec: mainSpec, depth: depth+1, index: indx, count: spec.dependencies.count, dep: subDep, allDependencies: allDependencies)
            }
        }
    }
    
    func printMapVisualAccuracy(mainSpec: ModuleSpec, depth: UInt, index:Int, count: Int, dep: DependencySpec, allDependencies: [DependencySpec]) {
        let users = whatDependsOn(dep, outOf: allDependencies)
        
        let names: [String] = users.map { (item) -> String in
            return item.name()
        }
        
        let usedBy = names.joined(separator: ", ")
        
        let explicit = mainSpec.dependencies.contains(dep)
        let padStr = "  "
        
        var startChar = "├─"
        let lineChar = "│"
        let endChar = "└─"
        
        if index == count-1 {
            startChar = endChar
        }
        
        var pad = padStr + lineChar
        for _ in 0..<depth {
            if index == count-1 {
             pad = padStr + " " + pad
            } else {
                pad = padStr + lineChar + pad
            }
        }
        
        let namePadRange = pad.range(of: lineChar, options: .backwards, range: nil, locale: nil)
        let namePad = pad.replacingOccurrences(of: lineChar, with: startChar, options: .anchored, range: namePadRange)
        
        writeln(.stdout, "\(pad)")
        writeln(.stdout, "\(namePad) name    : \(dep.name())")
        
        let otherPadRange = pad.range(of: lineChar, options: .backwards, range: nil, locale: nil)
        let otherPad = pad.replacingOccurrences(of: lineChar, with: " ", options: .anchored, range: otherPadRange)
         
        if index == count-1 {
            pad = otherPad
        }
        
        writeln(.stdout, "\(pad)  explicit: \(explicit)")
        if users.count > 0 {
            writeln(.stdout, "\(pad)  used by : \(usedBy)")
        }
        
        if let spec = ModuleSpec.load(dep) {
            for (indx, subDep) in spec.dependencies.enumerated() {
                printMapVisualAccuracy(mainSpec: mainSpec, depth: depth+1, index: indx, count: spec.dependencies.count, dep: subDep, allDependencies: allDependencies)
            }
        }
    }
}

