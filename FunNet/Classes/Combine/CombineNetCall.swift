//
//  CombineNetCall.swift
//  FunNet
//
//  Created by Elliot Schrock on 12/5/19.
//

import Combine

@available(iOS 13.0, *)
open class CombineNetCall: NetworkCall, Fireable {
    public typealias ResponderType = CombineNetworkResponder
    
    public var configuration: ServerConfigurationProtocol
    public var endpoint: EndpointProtocol
    public var responder: CombineNetworkResponder? = nil
    public var publisher: CombineNetworkResponder
    
    public var firingFunc: (CombineNetCall) -> Void = fire(_:)
    
    public init(configuration: ServerConfigurationProtocol, _ endpoint: EndpointProtocol, responder: CombineNetworkResponder? = CombineNetworkResponder()) {
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
