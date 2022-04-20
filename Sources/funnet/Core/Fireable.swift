//
//  Fireable.swift
//  FunNet
//
//  Created by Elliot on 4/19/22.
//

import Foundation

public protocol Fireable {
    func fire()
}

public func fireCall(_ call: Fireable) {
    call.fire()
}
