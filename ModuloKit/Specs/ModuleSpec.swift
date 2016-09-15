//
//  ModuleSpec.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/16/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
#if NOFRAMEWORKS
#else
    import ELCodable
    import ELFoundation
#endif

let specFilename = ".modulo"

public struct ModuleSpec {
    public let name: String
    public let module: Bool
    public let sourcePath: String?
    public var dependencies: [DependencySpec]
    
    public var path: String
}

extension ModuleSpec: Decodable {
    public static func decode(json: JSON?) throws -> ModuleSpec {
        return try ModuleSpec(
            name: json ==> "name",
            module: json ==> "module",
            sourcePath: json ==> "sourcePath",
            dependencies: json ==> "dependencies",
            path: ""
        )
    }
    
    public func validate() throws -> ModuleSpec {
        return self
    }
}

extension ModuleSpec: Encodable {
    public func encode() throws -> JSON {
        return try encodeToJSON([
            "name" <== name,
            "module" <== module,
            "sourcePath" <== sourcePath,
            "dependencies" <== dependencies
        ])
    }
}


extension ModuleSpec {
    public static func exists() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(specFilename)
    }
    
    public static func load(contentsOfFile filePath: String) -> ModuleSpec? {
        let json = JSON(path: filePath.resolvePath())
        var result = try? ModuleSpec.decode(json)
        
        if var spec = result {
            spec.path = filePath
            result = spec
        }
        
        return result
    }
    
    public static func load(dep: DependencySpec) -> ModuleSpec? {
        let depName = dep.repositoryURL.nameFromRemoteURL()
        
        let path = modulePath().appendPathComponent(depName).appendPathComponent(specFilename)
        return load(contentsOfFile: path)
    }
    
    public static func workingSpec() -> ModuleSpec? {
        let path = NSFileManager.workingPath().appendPathComponent(specFilename)

        return ModuleSpec.load(contentsOfFile: path)
    }
    
    public static func topLevelSpec() -> ModuleSpec? {
        // accounts for the initial /modules path.  Any deeper module paths will be symlinked.
        let path = NSFileManager.workingPath().appendPathComponent("../../\(specFilename)").resolvePath()
        if NSFileManager.fileExists(path) {
            return ModuleSpec.load(contentsOfFile: path)
        } else {
            return workingSpec()
        }
    }

    public static func modulePath() -> String {
        if let workSpec = workingSpec(), let topSpec = topLevelSpec() {
            var cleanedPath = workSpec.path.removeLastPathComponent().appendPathComponent("modules")
            if workSpec.path == topSpec.path {
                cleanedPath = "../"
            } else {
                // make sure the module path exists.
                if !NSFileManager.pathExists(cleanedPath) {
                    do {
                        try NSFileManager.defaultManager().createDirectoryAtPath(cleanedPath, withIntermediateDirectories: false, attributes: nil)
                    } catch {
                        assertionFailure("Unable to create path: \(cleanedPath)")
                    }
                }
            }
            
            return cleanedPath.resolvePath()
        } else {
            assertionFailure("Unable to determine module path!")
            return ""
        }
    }

    public func save() -> Bool {
        if path.isEmpty {
            assertionFailure("This module has no path set!")
        }
        
        var result = false
        let json = try? encode()
        
        if let _ = json, let data = json?.data() {
            let success = data.writeToFile(path, atomically: true)
            result = success
        }
        
        return result
    }
    
}


public extension ModuleSpec {
    public func allDependencies() -> [DependencySpec] {
        var deps = Set<DependencySpec>()
        
        deps.unionInPlace(dependencies)
        
        for dep in dependencies {
            if let spec = ModuleSpec.load(dep) {
                deps.unionInPlace(spec.dependencies)
            }
        }
        
        return [DependencySpec](deps)
    }
    
    public func dependencyForURL(repoURL: String) -> DependencySpec? {
        let results = dependencies.filter { (dep) -> Bool in
            return dep.repositoryURL == repoURL
        }
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    public func dependencyForName(name: String) -> DependencySpec? {
        let results = dependencies.filter { (dep) -> Bool in
            return dep.repositoryURL.nameFromRemoteURL().lowercaseString == name.lowercaseString
        }
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    public func addDependencies(inout toArray: [DependencySpec]) {
        for dep in dependencies {
            // is this dep already in the list?
            let existing = toArray.filter{ (arrayDep) -> Bool in
                return dep.repositoryURL == arrayDep.repositoryURL
            }
            
            // it's not in there already, so add it.
            if existing.count == 0 {
                toArray.append(dep)
            }
        }
    }
}

