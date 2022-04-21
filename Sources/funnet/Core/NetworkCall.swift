//
//  Fireable.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/8/19.
//

import Foundation
import Prelude
import LithoOperators

// Intentionally not public
enum Sessionizer {
    case config(URLSessionConfiguration)
    case session(URLSession)
}

open class NetworkCall {
    var sessionizer: Sessionizer
    public var baseUrl: URLComponents
    public var endpoint: Endpoint
    public var responder: NetworkResponder
    
    public init(configuration: ServerConfiguration, endpoint: Endpoint, responder: NetworkResponder = NetworkResponder()) {
        self.baseUrl = configuration.toBaseURL()
        self.sessionizer = .config(configuration.urlConfiguration)
        self.endpoint = endpoint
        self.responder = responder
    }
    
    public init(session: URLSession, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: NetworkResponder = NetworkResponder()) {
        self.baseUrl = baseUrlComponents
        self.sessionizer = .session(session)
        self.endpoint = endpoint
        self.responder = responder
    }
    
    public init(sessionConfig: URLSessionConfiguration, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: NetworkResponder = NetworkResponder()) {
        self.baseUrl = baseUrlComponents
        self.sessionizer = .config(sessionConfig)
        self.endpoint = endpoint
        self.responder = responder
    }
}

public func fire(_ call: NetworkCall) {
    let request = generateRequest(from: call.baseUrl, endpoint: call.endpoint)
    
    if let request = request {
        let dataTask: URLSessionDataTask?
        switch call.sessionizer {
        case .config(let sessionConfig):
            dataTask = generateDataTask(sessionConfiguration: sessionConfig,
                                        request: request,
                                        responder: call.responder)
        case .session(let session):
            dataTask = generateDataTask(session,
                                        request,
                                        responderToCompletion(responder: call.responder))
        }
        dataTask?.resume()
        call.responder.taskHandler(dataTask)
    }
}
