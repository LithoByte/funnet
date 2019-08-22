//
//  Endpoint.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import UIKit

public protocol EndpointProtocol {
    var httpMethod: String { get }
    var httpHeaders: [String: String] { get }
    var path: String { get }
    var postData: Data? { get }
}

public class Endpoint: EndpointProtocol {
    public var httpMethod: String = "GET"
    public var httpHeaders: [String: String] = [:]
    public var path: String = ""
    public var postData: Data? = nil
    
    public init() {}
}

public extension Endpoint {
    func addHeaders(headers: [String: String]) {
        for key in headers.keys {
            httpHeaders[key] = headers[key]
        }
    }
    
    func addModelData<E: Encodable>(model: E, encoder: JSONEncoder = JSONEncoder()) {
        self.postData = try? encoder.encode(model)
    }
}

public func dataSetter<T>(from model: T) -> (Endpoint) -> Void where T: Encodable {
    return { endpoint in
        endpoint.addModelData(model: model)
    }
}

public func addJsonHeaders(_ endpoint: Endpoint) {
    endpoint.addHeaders(headers: ["Content-Type": "application/json", "Accept": "application/json"])
}

public func setToPost(_ endpoint: Endpoint) {
    endpoint.httpMethod = "POST"
}

public func setToPut(_ endpoint: Endpoint) {
    endpoint.httpMethod = "PUT"
}

public func setToDelete(_ endpoint: Endpoint) {
    endpoint.httpMethod = "DELETE"
}
