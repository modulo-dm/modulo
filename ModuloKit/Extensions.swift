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
    
    public mutating func replace(string: String, replacement: String) {
        let range = rangeOfString(string)
        if let range = range {
            replaceRange(range, with: replacement)
        }
    }
    
    public func replace(string: String, replacement: String) -> String {
        var str = self
        let range = str.rangeOfString(string)
        if let range = range {
            str.replaceRange(range, with: replacement)
        }
        return str
    }
    
    func containsString(string: String) -> Bool {
        let range = rangeOfString(string)
        if range != nil {
            return true
        } else {
            return false
        }
    }
    
    func appendPathComponent(string: String) -> String {
        return ns.stringByAppendingPathComponent(string)
    }
    
    func nameFromRemoteURL() -> String {
        let gitURL = self
        let result = gitURL.ns.lastPathComponent.replace(".git", replacement: "")
        
        return result
    }
    
    func resolvePath() -> String {
        let resolved: NSString = self
        let result: String = resolved.stringByStandardizingPath
        return result
    }
    
    func removeLastPathComponent() -> String {
        let path: NSString = self
        let result: String = path.stringByDeletingLastPathComponent
        
        return result
    }
}

extension NSFileManager {
    public func temporaryFile() -> String {
        let guid = NSProcessInfo.processInfo().globallyUniqueString
        let filename = "\(guid)_file.txt"
        let filepath = NSTemporaryDirectory().ns.stringByAppendingPathComponent(filename)
        return filepath
    }
    
    public static func temporaryFile() -> String {
        return NSFileManager.defaultManager().temporaryFile()
    }
    
    public static func workingPath() -> String {
        return NSFileManager.defaultManager().currentDirectoryPath
    }
    
    public static func directoryName() -> String {
        return workingPath().ns.lastPathComponent
    }
    
    public static func setWorkingPath(path: String) -> Bool {
        return NSFileManager.defaultManager().changeCurrentDirectoryPath(path)
    }
    
    public static func fileExists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }

    public static func pathExists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    public static func symlink(path: String, destinationPath: String) -> Bool {
        do {
            try NSFileManager.defaultManager().createSymbolicLinkAtPath(path, withDestinationPath: destinationPath)
        } catch {
            return false
        }
        return true
    }
    
    public static func hardlink(srcPath: String, toPath: String) -> Bool {
        do {
            try NSFileManager.defaultManager().linkItemAtPath(srcPath, toPath: toPath)
        } catch {
            return false
        }
        return true
    }
    
    public static func isSymlink(path: String) -> Bool {
        do {
            let attrs = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            let value = attrs[NSFileTypeSymbolicLink]
            print(value)
            return true
        } catch {
            return false
        }
    }
    
    public static func areHardLinked(path1 path1: String, path2: String) -> Bool {
        var result = false
        do {
            let path1attr = try NSFileManager.defaultManager().attributesOfItemAtPath(path2)
            let path2attr = try NSFileManager.defaultManager().attributesOfItemAtPath(path1)
            
            // we're guaranteed to have the NSFile items in the dictionaries, so force unwrap it all.
            
            // file numbers are only unique per volume.
            let path1num = path1attr[NSFileSystemFileNumber] as! UInt
            let path2num = path2attr[NSFileSystemFileNumber] as! UInt
            // so get the volume numbers too.
            let path1vol = path1attr[NSFileSystemNumber] as! UInt
            let path2vol = path2attr[NSFileSystemNumber] as! UInt
            
            result = (path1num == path2num) && (path1vol == path2vol)
        } catch let error {
            print(error)
            result = false
        }
        
        return result
    }
        
}

extension Set {
    public mutating func insertArray(items: [Element]) {
        items.forEach { (item) in
            insert(item)
        }
    }
    
    public mutating func removeArray(items: [Element]) {
        items.forEach { (item) in
            remove(item)
        }
    }
}

