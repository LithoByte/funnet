//
//  Requests.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import Foundation
import Prelude
import LithoOperators

public func generateRequest(from configuration: ServerConfiguration, endpoint: Endpoint) -> URLRequest? {
    if !configuration.shouldUseCookies {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
    }
    
    var mutableRequest: URLRequest?
    if let url = configuration.url(for: endpoint) {
        mutableRequest = URLRequest.init(url: url)
        mutableRequest?.configure(from: endpoint)
    }
    
    return mutableRequest
}

public func generateRequest(from components: URLComponents, endpoint: Endpoint, logLevel: FunNetRequestLogLevel = .none) -> URLRequest? {
    var mutableRequest: URLRequest?
    if let url = components.url(for: endpoint) {
        mutableRequest = URLRequest.init(url: url)
        mutableRequest?.configure(from: endpoint)
    }
    switch logLevel {
    case .debug:
        print(mutableRequest)
        print("JSON body:")
        printJson(mutableRequest?.httpBody)
    case .methodAndUrl:
        print("\(mutableRequest?.httpMethod) \(mutableRequest?.url?.absoluteString)")
    case .curl:
        print(mutableRequest?.cURL())
    default: break
    }
    return mutableRequest
}

public func generateDataTask(sessionConfiguration: URLSessionConfiguration,
                             request: URLRequest,
                             responder: NetworkResponder) -> URLSessionDataTask? {
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

public func responderToCompletion(responder: NetworkResponder) -> (Data?, URLResponse?, Error?) -> Void {
    return handlersToCompletion(responseHandler: responder.responseHandler,
                                httpResponseHandler: responder.httpResponseHandler,
                                dataHandler: responder.dataHandler,
                                errorHandler: responder.errorHandler,
                                serverErrorHandler: responder.serverErrorHandler,
                                errorDataHandler: responder.errorDataHandler)
}

public func responderToTaskPublisherReceiver(responder: NetworkResponder) -> (Data?, URLResponse?) -> Void {
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

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
