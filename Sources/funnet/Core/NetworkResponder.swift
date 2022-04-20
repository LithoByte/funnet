//
//  NetworkResponder.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import Foundation

public protocol NetworkResponderProtocol {
    var taskHandler: (URLSessionDataTask?) -> Void { get set }
    var responseHandler: (URLResponse?) -> Void { get set }
    var httpResponseHandler: (HTTPURLResponse) -> Void { get set }
    var dataHandler: (Data?) -> Void { get set }
    var errorHandler: (NSError) -> Void { get set }
    var serverErrorHandler: (NSError) -> Void { get set }
    var errorDataHandler: (Data?) -> Void { get set }
}

public struct NetworkResponder: NetworkResponderProtocol {
    public var taskHandler: (URLSessionDataTask?) -> Void = { _ in }
    public var responseHandler: (URLResponse?) -> Void = { _ in }
    public var httpResponseHandler: (HTTPURLResponse) -> Void = { _ in }
    public var dataHandler: (Data?) -> Void = { _ in }
    public var errorHandler: (NSError) -> Void = { _ in }
    public var serverErrorHandler: (NSError) -> Void = { _ in }
    public var errorDataHandler: (Data?) -> Void = { _ in }
    
    public init() {}
}

public func stub<T: Codable>(_ responder: NetworkResponderProtocol, with model: T) -> (Fireable) -> Void {
    return { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            responder.dataHandler(try? JSONEncoder().encode(model))
        }
    }
}

public func stubNoDelay<T: Codable>(_ responder: NetworkResponderProtocol, with model: T) -> (Fireable) -> Void {
    return { _ in
        responder.dataHandler(try? JSONEncoder().encode(model))
    }
}

public func stubHTTPResponse<T: NetworkCall>(with statusCode: Int) -> (T) -> Void {
    return { call in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            call.responder?.httpResponseHandler(HTTPURLResponse(url: call.configuration.toBaseURL().url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!)
        }
    }
}

public func stubHTTPResponseNoDelay<T: NetworkCall>(with statusCode: Int) -> (T) -> Void {
    return { call in
        call.responder?.httpResponseHandler(HTTPURLResponse(url: call.configuration.toBaseURL().url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!)
    }
}
