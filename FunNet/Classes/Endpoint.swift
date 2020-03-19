//
//  Endpoint.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import UIKit

public protocol EndpointProtocol {
    var httpMethod: String { get set }
    var httpHeaders: [String: String] { get set }
    var path: String { get set }
    var getParams: [String: Any] { get set }
    var postData: Data? { get set }
}

public struct Endpoint: EndpointProtocol {
    public var httpMethod: String = "GET"
    public var httpHeaders: [String: String] = [:]
    public var getParams: [String: Any] = [:]
    public var path: String = ""
    public var postData: Data? = nil
    
    public init() {}
}

public extension EndpointProtocol {
    mutating func addHeaders(headers: [String: String]) {
        for key in headers.keys {
            httpHeaders[key] = headers[key]
        }
    }
    
    mutating func addModelData<E: Encodable>(model: E, encoder: JSONEncoder = JSONEncoder()) {
        self.postData = try? encoder.encode(model)
    }
    
    mutating func addGetParams(params: [String: String]) {
        for key in params.keys {
            getParams[key] = params[key]
        }
    }
}

public func dataSetter<M, T>(from model: M) -> (inout T) -> Void where M: Encodable, T: EndpointProtocol {
    return { (endpoint: inout T) in
        endpoint.addModelData(model: model)
    }
}

public func addJsonHeaders<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.addHeaders(headers: ["Content-Type": "application/json", "Accept": "application/json"])
}

public func setToGet<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "POST"
}

public func setToPost<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "POST"
}

public func setToPut<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "PUT"
}

public func setToDelete<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "DELETE"
}

public func setToGET<T>(_ endpoint: inout T) where T: EndpointProtocol {
    setToGet(&endpoint)
}

public func setToPOST<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "POST"
}

public func setToPUT<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "PUT"
}

public func setToDELETE<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "DELETE"
}
