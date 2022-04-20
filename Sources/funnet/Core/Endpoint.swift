//
//  Endpoint.swift
//  FunNet
//
//  Created by Elliot Schrock on 1/24/19.
//

import UIKit

public struct Endpoint {
    public var httpMethod: String = "GET"
    public var httpHeaders: [String: String] = [:]
    public var path: String = ""
    public var getParams: [URLQueryItem] = []
    public var timeout: TimeInterval = 60
    public var postData: Data?
    public var dataStream: InputStream?
    
    public init() {}
    
    public mutating func addHeaders(headers: [String: String]) {
        for key in headers.keys {
            httpHeaders[key] = headers[key]
        }
    }
    
    public mutating func addGetParams(params: [URLQueryItem]) {
        getParams.append(contentsOf: params)
    }
}

public func addJsonHeaders(_ endpoint: inout Endpoint) {
    endpoint.addHeaders(headers: jsonHeaders())
}

public func jsonHeaders() -> [String: String] {
    ["Content-Type": "application/json", "Accept": "application/json"]
}
