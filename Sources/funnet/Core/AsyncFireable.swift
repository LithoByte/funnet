//
//  AsyncFireable.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/4/24.
//

import Foundation

public protocol AsyncFireable {
    func fire() async throws -> Data?
}

public func fireAsyncCall(_ call: AsyncFireable) async throws -> Data? {
    try await call.fire()
}
