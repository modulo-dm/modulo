//
//  State.swift
//  ModuloKit
//
//  Created by Brandon Sneed on 6/16/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

public struct State {
    public static var instance = State()
    
    var module: Bool {
        return true
    }
    
    var implictDependencies = [DependencySpec]()
    var explicitDependencies = [DependencySpec]()
    
    public func showFinalInformation() {
        // look at what happened and print out some info
    }
}
