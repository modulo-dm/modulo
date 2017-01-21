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
    public static func decode(_ json: JSON?) throws -> ModuleSpec {
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
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: specFilename)
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
    
    public static func load(_ dep: DependencySpec) -> ModuleSpec? {
        let depName = dep.repositoryURL.nameFromRemoteURL()
        
        let path = modulePath().appendPathComponent(depName).appendPathComponent(specFilename)
        return load(contentsOfFile: path)
    }
    
    public static func workingSpec() -> ModuleSpec? {
        let path = FileManager.workingPath().appendPathComponent(specFilename)

        return ModuleSpec.load(contentsOfFile: path)
    }
    
    public static func topLevelSpec() -> ModuleSpec? {
        // accounts for the initial /modules path.  Any deeper module paths will be symlinked.
        let path = FileManager.workingPath().appendPathComponent("../../\(specFilename)").resolvePath()
        if FileManager.fileExists(path) {
            return ModuleSpec.load(contentsOfFile: path)
        } else {
            return workingSpec()
        }
    }

    public static func modulePath() -> String {
        if let workSpec = workingSpec()/*, let topSpec = topLevelSpec()*/ {
            var cleanedPath = workSpec.path.removeLastPathComponent().appendPathComponent(State.instance.modulePathName)
            if workSpec.module == true {
                cleanedPath = "../"
            } else {
                // make sure the module path exists.
                if !FileManager.pathExists(cleanedPath) {
                    do {
                        try FileManager.default.createDirectory(atPath: cleanedPath, withIntermediateDirectories: false, attributes: nil)
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

    @discardableResult
    public func save() -> Bool {
        if path.isEmpty {
            assertionFailure("This module has no path set!")
        }
        
        var result = false
        let json = try? encode()
        
        if let _ = json, let data = json?.data() {
            let success = (try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
            result = success
        }
        
        return result
    }
    
}


public extension ModuleSpec {
    public func allDependencies() -> [DependencySpec] {
        var deps = Set<DependencySpec>()
        
        deps.formUnion(dependencies)
        
        for dep in dependencies {
            if let spec = ModuleSpec.load(dep) {
                deps.formUnion(spec.dependencies)
            }
        }
        
        return [DependencySpec](deps)
    }
    
    @discardableResult
    public func dependencyForURL(_ repoURL: String) -> DependencySpec? {
        let results = dependencies.filter { (dep) -> Bool in
            return dep.repositoryURL == repoURL
        }
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    public func dependencyForName(_ name: String) -> DependencySpec? {
        let results = dependencies.filter { (dep) -> Bool in
            return dep.repositoryURL.nameFromRemoteURL().lowercased() == name.lowercased()
        }
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    public func addDependencies(_ toArray: inout [DependencySpec]) {
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
    
    public mutating func removeDependency(_ dep: DependencySpec) {
        dependencies = dependencies.filter { (item) in
            return dep.name() != item.name()
        }
    }
}

