# ELFoundation 

[![Version](https://img.shields.io/badge/version-v1.1.0-blue.svg)](https://github.com/Electrode-iOS/ELFoundation/releases/latest)
[![Build Status](https://travis-ci.org/Electrode-iOS/ELFoundation.svg?branch=master)](https://travis-ci.org/Electrode-iOS/ELFoundation)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

ELFoundation is a collection of Swift utilities for iOS development.

## Requirements

ELFoundation requires Swift 3 and Xcode 8.

## Installation

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "Electrode-iOS/ELFoundation" ~> 1.1.0
```

### Manual

Install by adding `ELFoundation.xcodeproj` to your project and configuring your target to link `ELFoundation.framework`.

## Usage

* `exceptionFailure` - A replacement for assertionFailure, usable in tests.
* `synchronized<T>` - Akin to @synchronized() in Objective-C.
* `Spinlock` - A basic spinlock implementation for synchronization.
* `Object Association` - Objective-C style object association.
* `Swizzling` - Objective-C style swizzling.
* `String (extensions)` - Handy extensions.
* `Array (extensions)` - Handy extensions.
* `NSObject (extensions)` - Handy extensions.
* `NSThread (extensions)` - Handy extensions.
* `NSError (extensions)` - Handy extensions.
* `NSBundle (extensions)` - Handy extensions.
* `XCTestCase (extensions)` - Gets XCTAssertThrows working in Swift.

## Some Examples

Synchronized property access:

```Swift
public var suspended: Bool {
    get {
        return lock.around {
            self.suspended
        }
    }
    
    set(value) {
        lock.around {
            self.suspended = value
        }
    }
}
```
