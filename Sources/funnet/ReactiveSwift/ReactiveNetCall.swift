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
    public typealias ResponderType = ReactiveNetworkResponder
    
    public var configuration: ServerConfigurationProtocol
    public var endpoint: EndpointProtocol
    public var responder: ReactiveNetworkResponder? = nil
    
    public var firingFunc: (ReactiveNetCall) -> Void = fire(_:)
    
    public init(configuration: ServerConfigurationProtocol, _ endpoint: EndpointProtocol, responder: ReactiveNetworkResponder? = ReactiveNetworkResponder()) {
        self.configuration = configuration
        self.endpoint = endpoint
        self.responder = responder
    }
    
    open func fire() {
        firingFunc(self)
    }
}

public class ReactiveNetworkResponder: NetworkResponderProtocol {
    public let dataTaskSignal: Signal<URLSessionDataTask, Never>
    public let downloadTaskSignal: Signal<URLSessionDownloadTask, Never>
    public let responseSignal: Signal<URLResponse, Never>
    public let httpResponseSignal: Signal<HTTPURLResponse, Never>
    public let dataSignal: Signal<Data?, Never>
    public let urlSignal: Signal<URL?, Never>
    public let errorSignal: Signal<NSError, Never>
    public let serverErrorSignal: Signal<NSError, Never>
    public let errorDataSignal: Signal<Data, Never>
    
    let dataTaskProperty = MutableProperty<URLSessionDataTask?>(nil)
    let downloadTaskProperty = MutableProperty<URLSessionDownloadTask?>(nil)
    let responseProperty = MutableProperty<URLResponse?>(nil)
    let httpResponseProperty = MutableProperty<HTTPURLResponse?>(nil)
    let dataProperty = MutableProperty<Data?>(nil)
    let urlProperty = MutableProperty<URL?>(nil)
    let errorProperty = MutableProperty<NSError?>(nil)
    let serverErrorProperty = MutableProperty<NSError?>(nil)
    let errorResponseProperty = MutableProperty<URLResponse?>(nil)
    let errorDataProperty = MutableProperty<Data?>(nil)
    
    public lazy var taskHandler: (URLSessionDataTask?) -> Void = { [weak self] in self?.dataTaskProperty.value = $0 }
    public lazy var downloadTaskHandler: (URLSessionDownloadTask?) -> Void = { [weak self] in
        self?.downloadTaskProperty.value = $0 }
    public lazy var responseHandler: (URLResponse?) -> Void = { [weak self] in self?.responseProperty.value = $0 }
    public lazy var httpResponseHandler: (HTTPURLResponse) -> Void = { [weak self] in self?.httpResponseProperty.value = $0 }
    public lazy var dataHandler: (Data?) -> Void = { [weak self] in self?.dataProperty.value = $0 }
    public lazy var urlHandler: (URL?) -> Void = { [weak self] in self?.urlProperty.value = $0 }
    public lazy var errorHandler: (NSError) -> Void = { [weak self] in self?.errorProperty.value = $0 }
    public lazy var serverErrorHandler: (NSError) -> Void = { [weak self] in self?.serverErrorProperty.value = $0 }
    public lazy var errorDataHandler: (Data?) -> Void = { [weak self] in self?.errorDataProperty.value = $0 }
    
    public init() {
        dataTaskSignal = dataTaskProperty.signal.skipNil()
        downloadTaskSignal = downloadTaskProperty.signal.skipNil()
        responseSignal = responseProperty.signal.skipNil()
        httpResponseSignal = httpResponseProperty.signal.skipNil()
        dataSignal = dataProperty.signal
        urlSignal = urlProperty.signal
        errorSignal = errorProperty.signal.skipNil()
        serverErrorSignal = serverErrorProperty.signal.skipNil()
        errorDataSignal = errorDataProperty.signal.skipNil()
    }
}
