//
//  State.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/16/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCLI
    import ELFoundation
#endif

public struct State {
    public static var instance = State()
    
    var implictDependencies = [DependencySpec]()
    var explicitDependencies = [DependencySpec]()
    var removedDependencies = [DependencySpec]()
    
    public func showFinalInformation() {
        writeln(.stdout, "")
        
        // look at what happened and print out some info
        if explicitDependencies.count > 0 {
            writeln(.stdout, "\nThe following dependencies were added:\n")
            explicitDependencies.forEach { (dep) in
                let repoName = dep.repositoryURL.nameFromRemoteURL()
                var repoPath = ModuleSpec.modulePath().appendPathComponent(repoName)
                if let depModule = ModuleSpec.load(dep) {
                    if let sourcePath = depModule.sourcePath {
                        repoPath = repoPath.appendPathComponent(sourcePath)
                    }
                }
                writeln(.stdout, "  \(repoName) in \(repoPath)")
            }
            //writeln(.stdout, "\n")
        }
        
        if implictDependencies.count > 0 {
            writeln(.stdout, "\nThe following dependencies were implicitly added by another module:\n")
            implictDependencies.forEach { (dep) in
                let repoName = dep.repositoryURL.nameFromRemoteURL()
                var repoPath = ModuleSpec.modulePath().appendPathComponent(repoName)
                if let depModule = ModuleSpec.load(dep) {
                    if let sourcePath = depModule.sourcePath {
                        repoPath = repoPath.appendPathComponent(sourcePath)
                    }
                }
                writeln(.stdout, "  \(repoName) in \(repoPath)")
            }
            //writeln(.stdout, "\n")
        }
        
        // we only want to show this if anything was added, implicit or explicit.
        if implictDependencies.count > 0 || explicitDependencies.count > 0 {
            writeln(.stdout, "\nDepending on your development toolchain, you may need to do some final steps to integrate the above dependencies in your project.\n")
        }
        
        // were any removed?
        if removedDependencies.count > 0 {
            if let workingSpec = ModuleSpec.workingSpec() {
                var reallyRemovedDeps = [DependencySpec]()
                let deps = workingSpec.allDependencies()
                removedDependencies.forEach{ (dep) in
                    if deps.contains(dep) == false {
                        reallyRemovedDeps.append(dep)
                    }
                }
                
                if reallyRemovedDeps.count > 0 {
                    writeln(.stdout, "The following dependencies have been removed, and no others use them:\n")
                    reallyRemovedDeps.forEach { (dep) in
                        let repoName = dep.repositoryURL.nameFromRemoteURL()
                        let repoPath = ModuleSpec.modulePath().appendPathComponent(repoName)
                        writeln(.stdout, "  \(repoName) in \(repoPath)")
                    }
                    writeln(.stdout, "\nTheir directories still remain, be sure you don't actually want them before deleting them yourself.\n")
                }
            }
        }
        // and we're all done.
    }
    
}
