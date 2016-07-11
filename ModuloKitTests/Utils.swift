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
    Git().remove("test-add")
    Git().remove("test-init")
    Git().remove("test-add-update")
    Git().remove("test-dep1")
    Git().remove("test-dep2")
}