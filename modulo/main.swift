//
//  main.swift
//  modulo
//
//  Created by Brandon Sneed on 6/17/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation

// such complexity! :D

/*
 
 The general idea is that we build with source, but we set ModuloKit as a target
 dependency.  That'll make sure it builds before modulo does.  Modulo then includes
 the source files from ModuloKit and the frameworks it depends on.  This will
 ensure that frameworks continue to build as changes are made in both source-only
 and framework form.
 
 ModuloKit then gives us a place by which we can write unit tests.
 
 */

Modulo.run()

