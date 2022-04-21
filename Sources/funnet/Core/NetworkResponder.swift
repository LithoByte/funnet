//
//  NetworkResponder.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import Foundation

public class NetworkResponder {
    public var taskHandler: (URLSessionDataTask?) -> Void = { _ in }
    public var responseHandler: (URLResponse?) -> Void = { _ in }
    public var httpResponseHandler: (HTTPURLResponse) -> Void = { _ in }
    public var dataHandler: (Data?) -> Void = { _ in }
    public var errorHandler: (NSError) -> Void = { _ in }
    public var serverErrorHandler: (NSError) -> Void = { _ in }
    public var errorDataHandler: (Data?) -> Void = { _ in }
    
    public init() {}
}

public func stub<T: Codable>(_ responder: NetworkResponder, with model: T) -> (Fireable) -> Void {
    return { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            responder.dataHandler(try? JSONEncoder().encode(model))
        }
    }
}

public func stubNoDelay<T: Codable>(_ responder: NetworkResponder, with model: T) -> (Fireable) -> Void {
    return { _ in
        responder.dataHandler(try? JSONEncoder().encode(model))
    }
}

public func stubHTTPResponse<T: NetworkCall>(with statusCode: Int) -> (T) -> Void {
    return { call in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            call.responder.httpResponseHandler(HTTPURLResponse(url: call.baseUrl.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!)
        }
    }
}

public func stubHTTPResponseNoDelay<T: NetworkCall>(with statusCode: Int) -> (T) -> Void {
    return { call in
        call.responder.httpResponseHandler(HTTPURLResponse(url: call.baseUrl.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!)
    }
}
