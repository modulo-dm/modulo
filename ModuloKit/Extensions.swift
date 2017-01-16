//
//  Extensions.swift
//  modulo
//
//  Created by Brandon Sneed on 1/24/16.
//  Copyright © 2016 Modulo. All rights reserved.
//

import Foundation

public extension String {
    public var ns: NSString { return (self as NSString) }
    
    /*public mutating func replace(string: String, replacement: String) {
        let range = rangeOfString(string)
        if let range = range {
            replaceRange(range, with: replacement)
        }
    }*/
    
    public func replace(_ string: String, replacement: String) -> String {
        let str = self.replacingOccurrences(of: string, with: replacement)
        
        return str
    }
    
    func containsString(_ string: String) -> Bool {
        let range = self.range(of: string)
        if range != nil {
            return true
        } else {
            return false
        }
    }
    
    func appendPathComponent(_ string: String) -> String {
        return ns.appendingPathComponent(string)
    }
    
    func nameFromRemoteURL() -> String {
        let gitURL = self
        let result = gitURL.ns.lastPathComponent.replace(".git", replacement: "")
        
        return result
    }
    
    func relativePath() -> String {
        let thisPath = self
        return thisPath.replace(FileManager.workingPath(), replacement: "")
    }
    
    func resolvePath() -> String {
        let resolved: NSString = self as NSString
        let result: String = resolved.standardizingPath
        return result
    }
    
    func lastPathComponent() -> String {
        let path: NSString = self as NSString
        let result: String = path.lastPathComponent
        
        return result
    }
    
    func removeLastPathComponent() -> String {
        let path: NSString = self as NSString
        let result: String = path.deletingLastPathComponent
        
        return result
    }
    
    func clean() -> String {
        var cc = characters
        
        loop: while true {
            switch cc.first {
            case nil:
                return ""
            case "\n"?, "\r"?, " "?, "\t"?, "\r\n"?:
                cc = cc.dropFirst()
            default:
                break loop
            }
        }
        
        loop: while true {
            switch cc.last {
            case nil:
                return ""
            case "\n"?, "\r"?, " "?, "\t"?, "\r\n"?:
                cc = cc.dropLast()
            default:
                break loop
            }
        }
        
        return String(cc)
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func stringByRemovingAll(_ characters: [Character]) -> String {
        return String(self.characters.filter({ !characters.contains($0) }))
    }
    
    func stringByRemovingAll(_ subStrings: [String]) -> String {
        var resultString = self
        _ = subStrings.map { resultString = resultString.replacingOccurrences(of: $0, with: "") }
        return resultString
    }
}

extension FileManager {
    public func temporaryFile() -> String {
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let filename = "\(guid)_file.txt"
        let filepath = NSTemporaryDirectory().ns.appendingPathComponent(filename)
        return filepath
    }
    
    public static func temporaryFile() -> String {
        return FileManager.default.temporaryFile()
    }
    
    public static func workingPath() -> String {
        return FileManager.default.currentDirectoryPath
    }
    
    public static func directoryName() -> String {
        return workingPath().ns.lastPathComponent
    }
    
    public static func setWorkingPath(_ path: String) {
        FileManager.default.changeCurrentDirectoryPath(path)
    }
    
    public static func fileExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    public static func pathExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    public static func symlink(_ path: String, destinationPath: String) -> Bool {
        do {
            try FileManager.default.createSymbolicLink(atPath: path, withDestinationPath: destinationPath)
        } catch {
            return false
        }
        return true
    }
    
    public static func hardlink(_ srcPath: String, toPath: String) -> Bool {
        do {
            try FileManager.default.linkItem(atPath: srcPath, toPath: toPath)
        } catch {
            return false
        }
        return true
    }
    
    /*public static func isSymlink(_ path: String) -> Bool {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path)
            let value = attrs[FileAttributeType.typeSymbolicLink] as! UInt
            return value
        } catch {
            return false
        }
    }*/
    
    public static func areHardLinked(path1: String, path2: String) -> Bool {
        var result = false
        do {
            let path1attr = try FileManager.default.attributesOfItem(atPath: path2)
            let path2attr = try FileManager.default.attributesOfItem(atPath: path1)
            
            // we're guaranteed to have the NSFile items in the dictionaries, so force unwrap it all.
            
            // file numbers are only unique per volume.
            let path1num = path1attr[FileAttributeKey.systemFileNumber] as! UInt
            let path2num = path2attr[FileAttributeKey.systemFileNumber] as! UInt
            // so get the volume numbers too.
            let path1vol = path1attr[FileAttributeKey.systemNumber] as! UInt
            let path2vol = path2attr[FileAttributeKey.systemNumber] as! UInt
            
            result = (path1num == path2num) && (path1vol == path2vol)
        } catch let error {
            print(error)
            result = false
        }
        
        return result
    }
        
}

extension Set {
    public mutating func insertArray(_ items: [Element]) {
        items.forEach { (item) in
            insert(item)
        }
    }
    
    public mutating func removeArray(_ items: [Element]) {
        items.forEach { (item) in
            remove(item)
        }
    }
}

