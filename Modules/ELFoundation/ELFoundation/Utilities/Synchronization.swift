//
//  Synchronization.swift
//  ELFoundation
//
//  Created by Brandon Sneed on 2/19/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

/**
 Mimics @synchronized(x) in Objective-C.  Synchronizes around the given object
 and executes the supplied closure.

 - parameter lock: Object to lock around.
 - parameter closure: Closure to execute inside of the lock.

 Example: synchronized(self) { doSomething() }
*/
public func synchronized(_ lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/**
 Mimics @synchronized(x) in Objective-C.  Synchronizes around the given object
 and executes the supplied closure, returning the type T.

 - parameter lock: Object to lock around.
 - parameter closure: Closure to execute inside of the lock.
 - returns: The result of the closure.

 Example: let running = synchronized(self) { return true }
*/
public func synchronized<T>(_ lock: AnyObject, closure: () -> T) -> T {
    objc_sync_enter(lock)
    let result: T = closure()
    objc_sync_exit(lock)
    return result
}

/**
 OS Level Spin Lock class.  Wraps the OSSpinLock* functions to allow for
 synchronization around a specified closure.  This is very useful for properties
 where get/set need to be thread-safe.
*/
final public class Spinlock {
    public init() {
        
    }
    
    /**
    Tries to acquire the lock, and if successful executes the specified closure.

    - parameter closure: Closure to execute inside of the lock.
    - returns: False if it failed to acquire the lock, otherwise true.
    */
    public func tryaround(_ closure: () -> Void) -> Bool {
        let held = OSSpinLockTry(&spinlock)
        if !held {
            closure()
            OSSpinLockUnlock(&spinlock)
        }
        return held
    }
    
    /**
    Runs the specified closure within the spin lock.
    
    - parameter closure: Closure to execute inside of the lock.
    */
    public func around(_ closure: () -> Void) {
        OSSpinLockLock(&spinlock)
        closure()
        OSSpinLockUnlock(&spinlock)
    }
    
    /**
    Runs the specified closure within the spin lock, returning the type T.
    
    - parameter closure: Closure to execute inside of the lock.
    - returns: The result of the closure.
    */
    public func around<T>(_ closure: () -> T) -> T {
        OSSpinLockLock(&spinlock)
        let result: T = closure()
        OSSpinLockUnlock(&spinlock)
        return result
    }
    
    public func lock() {
        OSSpinLockLock(&spinlock)
    }
    
    public func trylock() -> Bool {
        return OSSpinLockTry(&spinlock)
    }
    
    public func unlock() {
        OSSpinLockUnlock(&spinlock)
    }
    
    fileprivate var spinlock: OSSpinLock = OS_SPINLOCK_INIT
}
