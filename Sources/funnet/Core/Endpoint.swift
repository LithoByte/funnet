//
//  Endpoint.swift
//  FunNet
//
//  Created by Elliot Schrock on 1/24/19.
//

import UIKit

public struct Endpoint: Equatable {
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

extension Endpoint {
    public var method: HttpMethod {
        get { HttpMethod(rawValue: httpMethod) }
        set { httpMethod = newValue.rawValue }
    }
}

public struct HttpMethod: RawRepresentable {
    public static let get = HttpMethod(rawValue: "GET")
    public static let post = HttpMethod(rawValue: "POST")
    public static let put = HttpMethod(rawValue: "PUT")
    public static let patch = HttpMethod(rawValue: "PATCH")
    public static let delete = HttpMethod(rawValue: "DELETE")

    public static let connect = HttpMethod(rawValue: "CONNECT")
    public static let head = HttpMethod(rawValue: "HEAD")
    public static let options = HttpMethod(rawValue: "OPTIONS")
    public static let query = HttpMethod(rawValue: "QUERY")
    public static let trace = HttpMethod(rawValue: "TRACE")

    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
extension HttpMethod: Codable {}
extension HttpMethod: Equatable {}
extension HttpMethod: Hashable {}

public func setToGET(_ endpoint: inout Endpoint) {
    endpoint.method = HttpMethod.get
}

public func setToPOST(_ endpoint: inout Endpoint) {
    endpoint.method = HttpMethod.post
}

public func setToPUT(_ endpoint: inout Endpoint) {
    endpoint.method = HttpMethod.put
}

public func setToPATCH(_ endpoint: inout Endpoint) {
    endpoint.method = HttpMethod.patch
}

public func setToDELETE(_ endpoint: inout Endpoint) {
    endpoint.method = HttpMethod.delete
}

public func addJsonHeaders(_ endpoint: inout Endpoint) {
    endpoint.addHeaders(headers: jsonHeaders())
}

public func jsonHeaders() -> [String: String] {
    ["Content-Type": "application/json", "Accept": "application/json"]
}
