//
//  Fireable.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/8/19.
//

import Foundation
import Prelude
import LithoOperators

public protocol NetworkCall: AnyObject {
    associatedtype ResponderType: NetworkResponderProtocol
    
    var configuration: ServerConfiguration { get set }
    var endpoint: Endpoint { get set }
    var responder: ResponderType? { get set }
}

public func fire<T>(_ call: T) where T: NetworkCall {
    fire(call, with: call.responder)
}

public func fire<T>(_ call: T, with responder: NetworkResponderProtocol?) where T: NetworkCall {
    let request = generateRequest(from: call.configuration, endpoint: call.endpoint)
    
    if let request = request {
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
}
