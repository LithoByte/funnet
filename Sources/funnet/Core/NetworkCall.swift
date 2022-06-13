//
//  Fireable.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/8/19.
//

import Foundation
import Prelude
import LithoOperators

/**
 Only three levels of request logging:
 - on production, you shouldn't log anything, so, none;
 - when you're debugging, you need everything;
 - sometimes you just need the sequence, so just the url and HTTP method;
 - and sometimes you want to try it from the command line, so, curl.
 To log server responses, use the responder and your standard print statements
 */
public enum FunNetRequestLogLevel {
    case none, debug, methodAndUrl, curl
}

// Intentionally not public
enum Sessionizer {
    case config(URLSessionConfiguration)
    case session(URLSession)
}

open class NetworkCall: Fireable {
    var sessionizer: Sessionizer
    public var baseUrl: URLComponents
    public var endpoint: Endpoint
    public var responder: NetworkResponder
    
    public var requestLogLevel: FunNetRequestLogLevel = .none
    
    public var reset: (NetworkCall) -> Void = { _ in }
    public var firingFunc: (NetworkCall) -> Void = fire(_:)
    
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
    
    @objc open func fire() {
        firingFunc(self)
    }
    
    @objc open func resetAndFire() {
        reset(self)
        firingFunc(self)
    }
}

public func fire(_ call: NetworkCall) {
    let request = generateRequest(from: call.baseUrl, endpoint: call.endpoint, logLevel: call.requestLogLevel)
    
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
