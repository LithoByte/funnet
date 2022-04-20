//
//  CombineNetCall.swift
//  FunNet
//
//  Created by Elliot Schrock on 12/5/19.
//

import Foundation
import Combine

#if canImport(Core)
    import Core
#endif

@available(iOS 13.0, *)
open class CombineNetCall: NetworkCall, Fireable {
    public typealias ResponderType = CombineNetworkResponder
    
    public var configuration: ServerConfiguration
    public var endpoint: Endpoint
    public var responder: CombineNetworkResponder? = nil
    public var publisher: CombineNetworkResponder
    
    public var firingFunc: (CombineNetCall) -> Void = fire(_:)
    
    public init(configuration: ServerConfiguration, _ endpoint: Endpoint, responder: CombineNetworkResponder? = CombineNetworkResponder()) {
        self.configuration = configuration
        self.endpoint = endpoint
        self.publisher = responder ?? CombineNetworkResponder()
        self.responder = responder
    }
    
    open func fire() {
        firingFunc(self)
    }
}

@available(iOS 13.0, *)
public class CombineNetworkResponder: NetworkResponderProtocol {
    @Published public var dataTask: URLSessionDataTask?
    @Published public var response: URLResponse?
    @Published public var httpResponse: HTTPURLResponse?
    @Published public var data: Data?
    @Published public var error: NSError?
    @Published public var serverError: NSError?
    @Published public var errorResponse: URLResponse?
    @Published public var errorData: Data?
    
    public lazy var taskHandler: (URLSessionDataTask?) -> Void = { [weak self] in self?.dataTask = $0 }
    public lazy var responseHandler: (URLResponse?) -> Void = { [weak self] in self?.response = $0 }
    public lazy var httpResponseHandler: (HTTPURLResponse) -> Void = { [weak self] in self?.httpResponse = $0 }
    public lazy var dataHandler: (Data?) -> Void = { [weak self] in self?.data = $0 }
    public lazy var errorHandler: (NSError) -> Void = { [weak self] in self?.error = $0 }
    public lazy var serverErrorHandler: (NSError) -> Void = { [weak self] in self?.serverError = $0 }
    public lazy var errorDataHandler: (Data?) -> Void = { [weak self] in self?.errorData = $0 }
    
    public init() {}
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

//@available(iOS 13.0, *)
//extension Publishers.MakeConnectable: Fireable {
//    public func fire() {
//        connect()
//    }
//}

//@available(iOS 13.0, *)
//public extension URLSession {
//    func combineNetworkResponder(from request: URLRequest) -> CombineNetworkResponder {
//        let responder = CombineNetworkResponder()
//        let task = dataTask(with: request, completionHandler: responderToCompletion(responder: responder))
//        responder.taskHandler(task)
//        return responder
//    }
//}
