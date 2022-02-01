//
//  Requests.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import Foundation
import Prelude
import LithoOperators

public func generateRequest(from configuration: ServerConfigurationProtocol, endpoint: EndpointProtocol) -> URLRequest {
    let configure = (endpoint.httpMethod *-> applyHttpMethod)
        <> (endpoint.httpHeaders *-> applyHeaders)
        <> (endpoint.postData *-> applyBody)
        <> (endpoint.dataStream *-> applyStream)
        <> (endpoint.timeout *-> applyTimeout)
        <> (ignoreArg(configuration.shouldUseCookies *> applyCookiePolicy))
    
    let mutableRequest = configuration.urlString(for: endpoint) |>
        (URL.init(string:) >?> NSMutableURLRequest.init(url:))
    if let request = mutableRequest {
        configure(request)
    }
    return mutableRequest! as URLRequest
}

public func generateDataTask(sessionConfiguration: URLSessionConfiguration,
                      request: URLRequest,
                      responder: NetworkResponderProtocol) -> URLSessionDataTask? {
    return generateDataTask(sessionConfiguration: sessionConfiguration,
                            request: request,
                            responderToCompletion(responder: responder))
}

public func generateDataTask(sessionConfiguration: URLSessionConfiguration,
                      request: URLRequest,
                      _ completion: @escaping (Data?, URLResponse?, Error?) -> Void = { _, _, _ in })
    -> URLSessionDataTask? {
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        return generateDataTask(session, request) { (data, response, error) in
            completion(data, response, error)
            session.finishTasksAndInvalidate()
        }
}

public func generateDataTask(_ session: URLSession, _ request: URLRequest, _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
    return session.dataTask(with: request, completionHandler: completion)
}

public func responderToCompletion(responder: NetworkResponderProtocol) -> (Data?, URLResponse?, Error?) -> Void {
    return handlersToCompletion(responseHandler: responder.responseHandler,
                                httpResponseHandler: responder.httpResponseHandler,
                                dataHandler: responder.dataHandler,
                                errorHandler: responder.errorHandler,
                                serverErrorHandler: responder.serverErrorHandler,
                                errorDataHandler: responder.errorDataHandler)
}

public func responderToTaskPublisherReceiver(responder: NetworkResponderProtocol) -> (Data?, URLResponse?) -> Void {
    return handlersToTaskPublisherBlock(responseHandler: responder.responseHandler,
                                httpResponseHandler: responder.httpResponseHandler,
                                dataHandler: responder.dataHandler,
                                serverErrorHandler: responder.serverErrorHandler,
                                errorDataHandler: responder.errorDataHandler)
}

public func handlersToCompletion(responseHandler: @escaping (URLResponse?) -> Void = { _ in },
                                 httpResponseHandler: @escaping (HTTPURLResponse) -> Void = { _ in },
                                 dataHandler: @escaping (Data?) -> Void = { _ in },
                                 errorHandler: @escaping (NSError) -> Void = { _ in },
                                 serverErrorHandler: @escaping (NSError) -> Void = { _ in },
                                 errorDataHandler: @escaping (Data?) -> Void = { _ in })
    -> (Data?, URLResponse?, Error?) -> Void {
    return { (data, response, error) in
        responseHandler(response)
        if let e = error as NSError? {
            errorHandler(e)
            errorDataHandler(data)
        } else if let httpResponse = response as? HTTPURLResponse {
            httpResponseHandler(httpResponse)
            if httpResponse.statusCode > 299 {
                var info: [String: Any] = ["url" : httpResponse.url?.absoluteString as Any]
                if let data = data {
                    errorDataHandler(data)
                    if let stringData = String(data: data, encoding: .utf8) {
                        info["data"] = stringData
                    }
                }
                serverErrorHandler(NSError(domain: "Server", code: httpResponse.statusCode, userInfo: info))
            } else {
                dataHandler(data)
            }
        }
    }
}

public func handlersToTaskPublisherBlock(responseHandler: @escaping (URLResponse?) -> Void = { _ in },
                                 httpResponseHandler: @escaping (HTTPURLResponse) -> Void = { _ in },
                                 dataHandler: @escaping (Data?) -> Void = { _ in },
                                 serverErrorHandler: @escaping (NSError) -> Void = { _ in },
                                 errorDataHandler: @escaping (Data?) -> Void = { _ in })
    -> (Data?, URLResponse?) -> Void {
    return { (data, response) in
        responseHandler(response)
        if let httpResponse = response as? HTTPURLResponse {
            httpResponseHandler(httpResponse)
            if httpResponse.statusCode < 300 {
                dataHandler(data)
            } else {
                (data, response) |> (~responseToServerError() >?> serverErrorHandler)
            }
        }
    }
}

public func responseToServerError() -> (Data?, URLResponse?) -> NSError? {
    return { (data, response) in
        var error: NSError? = nil
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode > 299 {
                var info: [String: Any] = ["url" : httpResponse.url?.absoluteString as Any]
                if let data = data {
                    info["data"] = data
                    if let stringData = String(data: data, encoding: .utf8) {
                        info["data"] = stringData
                    }
                }
                error = NSError(domain: "Server", code: httpResponse.statusCode, userInfo: info)
            }
        }
        return error
    }
}

public func applyHttpMethod(method: String = "GET", request: NSMutableURLRequest) -> Void {
    request.httpMethod = method
}

public func applyHeaders(_ httpHeaders: [String: String] = [:], request: NSMutableURLRequest) {
    for key in httpHeaders.keys {
        request.addValue(httpHeaders[key]!, forHTTPHeaderField: key)
    }
}

public func applyCookiePolicy(_ shouldApplyCookies: Bool) {
    if !shouldApplyCookies {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
    }
}

public func applyBody(_ postData: Data?, request: NSMutableURLRequest) {
    request.httpBody = postData
}

public func applyStream(_ stream: InputStream?, request: NSMutableURLRequest) {
    if let stream = stream {
        request.httpBodyStream = stream
    }
}

public func applyTimeout(interval: TimeInterval, request: NSMutableURLRequest) {
    request.timeoutInterval = interval
}
