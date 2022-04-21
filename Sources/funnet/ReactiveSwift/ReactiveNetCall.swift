//
//  ReactiveNetCall.swift
//  LithoUXComponents
//
//  Created by Elliot Schrock on 8/22/19.
//

import Foundation
import ReactiveSwift

#if canImport(Core)
    import Core
#endif

open class ReactiveNetCall: NetworkCall, Fireable {
    public var reactiveResponder: ReactiveNetworkResponder
    
    public var firingFunc: (ReactiveNetCall) -> Void = fire(_:)
    
    public init(configuration: ServerConfiguration, _ endpoint: Endpoint, responder: ReactiveNetworkResponder = ReactiveNetworkResponder()) {
        reactiveResponder = responder
        super.init(configuration: configuration, endpoint: endpoint, responder: responder)
    }
    
    public init(session: URLSession, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: ReactiveNetworkResponder = ReactiveNetworkResponder()) {
        reactiveResponder = responder
        super.init(session: session, baseUrlComponents: baseUrlComponents, endpoint: endpoint, responder: responder)
    }
    
    public init(sessionConfig: URLSessionConfiguration, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: ReactiveNetworkResponder = ReactiveNetworkResponder()) {
        reactiveResponder = responder
        super.init(sessionConfig: sessionConfig, baseUrlComponents: baseUrlComponents, endpoint: endpoint, responder: responder)
    }
    
    open func fire() {
        firingFunc(self)
    }
}

public class ReactiveNetworkResponder: NetworkResponder {
    public let dataTaskSignal: Signal<URLSessionDataTask, Never>
    public let responseSignal: Signal<URLResponse, Never>
    public let httpResponseSignal: Signal<HTTPURLResponse, Never>
    public let dataSignal: Signal<Data?, Never>
    public let errorSignal: Signal<NSError, Never>
    public let serverErrorSignal: Signal<NSError, Never>
    public let errorDataSignal: Signal<Data, Never>
    
    let dataTaskProperty = MutableProperty<URLSessionDataTask?>(nil)
    let responseProperty = MutableProperty<URLResponse?>(nil)
    let httpResponseProperty = MutableProperty<HTTPURLResponse?>(nil)
    let dataProperty = MutableProperty<Data?>(nil)
    let errorProperty = MutableProperty<NSError?>(nil)
    let serverErrorProperty = MutableProperty<NSError?>(nil)
    let errorResponseProperty = MutableProperty<URLResponse?>(nil)
    let errorDataProperty = MutableProperty<Data?>(nil)
    
    public override init() {
        dataTaskSignal = dataTaskProperty.signal.skipNil()
        responseSignal = responseProperty.signal.skipNil()
        httpResponseSignal = httpResponseProperty.signal.skipNil()
        dataSignal = dataProperty.signal
        errorSignal = errorProperty.signal.skipNil()
        serverErrorSignal = serverErrorProperty.signal.skipNil()
        errorDataSignal = errorDataProperty.signal.skipNil()
        
        super.init()
        
        self.taskHandler = { [weak self] in self?.dataTaskProperty.value = $0 }
        self.responseHandler = { [weak self] in self?.responseProperty.value = $0 }
        self.httpResponseHandler = { [weak self] in self?.httpResponseProperty.value = $0 }
        self.dataHandler = { [weak self] in self?.dataProperty.value = $0 }
        self.errorHandler = { [weak self] in self?.errorProperty.value = $0 }
        self.serverErrorHandler = { [weak self] in self?.serverErrorProperty.value = $0 }
        self.errorDataHandler = { [weak self] in self?.errorDataProperty.value = $0 }
    }
}
