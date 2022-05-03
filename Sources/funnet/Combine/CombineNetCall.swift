//
//  CombineNetCall.swift
//  FunNet
//
//  Created by Elliot Schrock on 12/5/19.
//

import Foundation
import Combine
import LithoOperators
#if canImport(Core)
    import Core
#endif

@available(iOS 13.0, *)
open class CombineNetCall: NetworkCall {
    @Published public var isInProgress: Bool = false
    public var publisher: CombineNetworkResponder {
        didSet {
            publisher.responseHandler <>= { [weak self] _ in self?.isInProgress = false }
            publisher.dataHandler <>= { [weak self] _ in self?.isInProgress = false }
            publisher.errorHandler <>= { [weak self] _ in self?.isInProgress = false }
        }
    }
    
    public init(configuration: ServerConfiguration, _ endpoint: Endpoint, responder: CombineNetworkResponder = CombineNetworkResponder()) {
        publisher = responder
        super.init(configuration: configuration, endpoint: endpoint, responder: responder)
    }
    
    public init(session: URLSession, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: CombineNetworkResponder = CombineNetworkResponder()) {
        publisher = responder
        super.init(session: session, baseUrlComponents: baseUrlComponents, endpoint: endpoint, responder: responder)
    }
    
    public init(sessionConfig: URLSessionConfiguration, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: CombineNetworkResponder = CombineNetworkResponder()) {
        publisher = responder
        super.init(sessionConfig: sessionConfig, baseUrlComponents: baseUrlComponents, endpoint: endpoint, responder: responder)
    }
    
    open override func fire() {
        isInProgress = true
        firingFunc(self)
    }
}

@available(iOS 13.0, *)
public class CombineNetworkResponder: NetworkResponder {
    @Published public var dataTask: URLSessionDataTask?
    @Published public var response: URLResponse?
    @Published public var httpResponse: HTTPURLResponse?
    @Published public var data: Data?
    @Published public var error: NSError?
    @Published public var serverError: NSError?
    @Published public var errorResponse: URLResponse?
    @Published public var errorData: Data?
    
    public override init() {
        super.init()
        self.taskHandler = { [weak self] in self?.dataTask = $0 }
        self.responseHandler = { [weak self] in self?.response = $0 }
        self.httpResponseHandler = { [weak self] in self?.httpResponse = $0 }
        self.dataHandler = { [weak self] in self?.data = $0 }
        self.errorHandler = { [weak self] in self?.error = $0 }
        self.serverErrorHandler = { [weak self] in self?.serverError = $0 }
        self.errorDataHandler = { [weak self] in self?.errorData = $0 }
    }
}

@available(iOS 13.0, *)
public extension Publisher {
    func asConnectable() -> Publishers.MakeConnectable<Self> {
        return .init(upstream: self)
    }
}

@available(iOS 13.0, *)
public extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func serverErrorPublisher() -> Publishers.Map<Self, NSError?> {
        return self.map(responseToServerError())
    }
}

@available(iOS 13.0, *)
public extension URLSession {
    func combineNetworkResponder(from request: URLRequest) -> CombineNetworkResponder {
        let responder = CombineNetworkResponder()
        let task = dataTask(with: request, completionHandler: responderToCompletion(responder: responder))
        responder.taskHandler(task)
        return responder
    }
}
