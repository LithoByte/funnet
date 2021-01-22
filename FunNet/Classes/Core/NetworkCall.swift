//
//  Fireable.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/8/19.
//

import Prelude
import LithoOperators

public protocol NetworkCall: class {
    associatedtype ResponderType: NetworkResponderProtocol
    
    var configuration: ServerConfigurationProtocol { get set }
    var endpoint: EndpointProtocol { get set }
    var responder: ResponderType? { get set }
}

public protocol Fireable {
    func fire()
}

public func callFirer(_ call: Fireable) {
    call.fire()
}

public func fire<T>(_ call: T) where T: NetworkCall {
    fire(call, with: call.responder)
}

//public func fireStubbable<T>(_ call: T) where T: NetworkCall & Stubbable {
//    var removeStub: (URLResponse?) -> Void = { _ in }
//    if let stubHolder = call.stubHolder, call.configuration.shouldStub {
//        var stubbable = call
//        let stubDesc = stub(condition: stubbable.stubCondition, response: stubHolder.stubResponseBlock())
//        removeStub = { _ in OHHTTPStubs.removeStub(stubDesc) }
//    }
//    
//    var networkResponder: NetworkResponderProtocol
//    if var responder = call.responder {
//        responder.responseHandler = (removeStub <> responder.responseHandler)
//        networkResponder = responder
//    } else {
//        networkResponder = NetworkResponder()
//        networkResponder.responseHandler = removeStub
//    }
//    
//    fire(call, with: networkResponder)
//}

public func fire<T>(_ call: T, with responder: NetworkResponderProtocol?) where T: NetworkCall {
    let request = generateRequest(from: call.configuration, endpoint: call.endpoint)
    
    let dataTask: URLSessionDataTask?
    if let responder = responder {
        dataTask = generateDataTask(sessionConfiguration: call.configuration.urlConfiguration,
                                    request: request,
                                    responder: responder)
    } else {
        dataTask = generateDataTask(sessionConfiguration: call.configuration.urlConfiguration,
                                    request: request)
    }
    
    dataTask?.resume()
    call.responder?.taskHandler(dataTask)
}
