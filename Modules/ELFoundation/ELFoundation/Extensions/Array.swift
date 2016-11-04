//
//  Array.swift
//  ELFoundation
//
//  Created by Brandon Sneed on 4/4/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation

/**
 Creates a new array by removing `items` from `fromArray`

 - parameter items: Array of items to remove.
 - parameter fromArray: Array to remove items from.
 - returns: A new array with the specified items removed.
*/
@available(*, deprecated: 0.0.3, message: "Use array.excludeElements(items) instead")
public func arrayByRemoving<T: Equatable>(_ items: Array<T>, fromArray: Array<T>) -> Array<T> {
    return fromArray.excludeElements(items)
}


// MARK: Iteration helpers

public extension Array {
    /**
    Runs the specified block against each element in the array.
    example:
        array.each {
            $0.doSomething()
        }
    */
    func each(_ block: (_ object: Element) -> Void) {
        for object in self {
            block(object)
        }
    }
    
    /**
    Runs the specified block against each element in the array by index.
    example:
        array.eachWithIndex { (object, index) -> Void in
            object.doSomethingWithIndex(index)
        }
    */
    func eachWithIndex(_ block: (_ object: Element, _ index: Int) -> Void) {
        for (index, object) in self.enumerated() {
            block(object, index)
        }
    }
    
}

// MARK: Stack and Queue helpers

public extension Array {
    
    //Stack - LIFO
    mutating func push(_ newElement: Element) {
        self.append(newElement)
    }
    
    mutating func pop() -> Element? {
        if self.count > 0 {
            return self.removeLast()
        }
        return nil
    }
    
    func peekAtStack() -> Element? {
        if self.count > 0 {
            return self.last
        }
        return nil
    }
    
    //Queue - FIFO
    mutating func enqueue(_ newElement: Element) {
        self.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        if self.count > 0 {
            return self.remove(at: 0)
        }
        return nil
    }
    
    func peekAtQueue() -> Element? {
        if self.count > 0 {
            return self.first
        }
        return nil
    }
}

// MARK: Object removal helpers.

public extension Array where Element : Equatable {
    /**
     Removes each occurrence of `element` from this array.
     
     **This method is deprecated. Please use `removeElement(element: Element)` instead.**
     */
    @available(*, deprecated: 0.0.3, renamed: "removeElement")
    mutating func removeObject(_ object : Iterator.Element) {
        self.removeElement(object)
    }

    /**
     Removes each occurrence of `element` from this array.
     */
    @available(*, introduced: 0.0.3)
    mutating func removeElement(_ element: Element) {
        while let index = self.index(of: element) {
            self.remove(at: index)
        }
    }

    /**
     Removes each occurrence of each of the `elements` from this array.

     - Parameter elements: Sequence containing elements to remove.
     */
    @available(*, introduced: 0.0.3)
    mutating func removeElements<S: Sequence>(_ elements: S) where S.Iterator.Element == Element {
        for element in elements {
            self.removeElement(element)
        }
    }

    /**
     Returns a copy of the array with each instance of items in `elements` removed.
     
     - Parameter elements: Sequence containing elements to remove.
     */
    @available(*, introduced: 0.0.3)
    func excludeElements(_ elements: [Element]) -> [Element] {
        var array = self
        array.removeElements(elements)
        return array
    }
}
