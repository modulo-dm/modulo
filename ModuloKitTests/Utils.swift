//
//  Utils.swift
//  modulo
//
//  Created by Brandon Sneed on 7/11/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

import Foundation
import ELCLI
import ELFoundation
@testable import ModuloKit

func clearTestRepos() {
    FileManager.setWorkingPath("/private/tmp")
    Git().remove("test-dummy")
    Git().remove("test-add")
    Git().remove("test-init")
    Git().remove("test-add-update")
    Git().remove("test-dep1")
    Git().remove("test-dep2")
}

func touchFile(_ path: String) {
    try! path.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
}

func runCommand(_ command: String) {
    Git().runCommand(command)
}
