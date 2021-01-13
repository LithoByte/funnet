//
//  Endpoint.swift
//  FunNet
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
    var dataStream: InputStream? { get set }
}

public struct Endpoint: EndpointProtocol {
    public var httpMethod: String = "GET"
    public var httpHeaders: [String: String] = [:]
    public var getParams: [String: Any] = [:]
    public var path: String = ""
    public var postData: Data?
    public var dataStream: InputStream?
    
    public init() {}
}

public extension EndpointProtocol {
    mutating func addHeaders(headers: [String: String]) {
        for key in headers.keys {
            httpHeaders[key] = headers[key]
        }
    }
    
    mutating func addModelData<E: Encodable>(model: E, encoder: FormDataEncoder = FormDataEncoder()) {
        let boundary = "--boundary-pds-site\(Date().timeIntervalSince1970)file-image-boundary--"
        guard let formData = try? encoder.encode(model, boundary: boundary) else { return }
        let stream = formData.makeInputStream()
        self.postData = try? Data(reading: stream)
    }
    
    mutating func addModelStream<E: Encodable>(model: E, encoder: JSONEncoder = JSONEncoder()) {
        self.dataStream = try? InputStream(data: encoder.encode(model))
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

public func addMultipartHeaders<T>(_ endpoint: inout T, from multipartData: MultipartFormData) where T: EndpointProtocol {
    endpoint.addHeaders(headers: [
        "Content-Type": "multipart/form-data; charset=utf-8; boundary=\"\(multipartData.boundary)\"",
        "Content-Length": "\(multipartData.countContentLength())",
        "Accept": "application/json"
    ])
}

public func setToGet<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "GET"
}

public func setToPost<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "POST"
}

public func setToPut<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "PUT"
}

public func setToPatch<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "PATCH"
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

public func setToPATCH<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "PATCH"
}

public func setToDELETE<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.httpMethod = "DELETE"
}
