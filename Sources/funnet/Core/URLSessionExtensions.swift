//
//  URLSessionExtensions.swift
//  FunNet
//
//  Created by Elliot on 4/19/22.
//

import Foundation
import Combine

extension URLSessionDataTask: Fireable {
    public func fire() {
        resume()
    }
}

public extension URLRequest {
    mutating func configure(from endpoint: Endpoint) {
        for key in endpoint.httpHeaders.keys {
            self.addValue(endpoint.httpHeaders[key]!, forHTTPHeaderField: key)
        }
        self.httpMethod = endpoint.httpMethod
        self.httpBody = endpoint.postData
        self.httpBodyStream = endpoint.dataStream
        self.timeoutInterval = endpoint.timeout
    }
}
