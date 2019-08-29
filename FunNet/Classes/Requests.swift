//
//  Requests.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import Prelude

public func generateRequest(from configuration: ServerConfigurationProtocol, endpoint: EndpointProtocol) -> URLRequest {
    let configure = (endpoint.httpMethod >|> applyHttpMethod)
        <> (endpoint.httpHeaders >|> applyHeaders)
        <> (endpoint.postData >|> applyBody)
    
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
                            responseHandler: responder.responseHandler,
                            httpResponseHandler: responder.httpResponseHandler,
                            dataHandler: responder.dataHandler,
                            errorHandler: responder.errorHandler,
                            serverErrorHandler: responder.serverErrorHandler,
                            errorDataHandler: responder.errorDataHandler)
}

public func generateDataTask(sessionConfiguration: URLSessionConfiguration,
                      request: URLRequest,
                      responseHandler: @escaping (URLResponse?) -> Void = { _ in },
                      httpResponseHandler: @escaping (HTTPURLResponse) -> Void = { _ in },
                      dataHandler: @escaping (Data?) -> Void = { _ in },
                      errorHandler: @escaping (NSError) -> Void = { _ in },
                      serverErrorHandler: @escaping (NSError) -> Void = { _ in },
                      errorDataHandler: @escaping (Data?) -> Void = { _ in })
    -> URLSessionDataTask? {
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        return session.dataTask(with: request as URLRequest) { (data, response, error) in
            responseHandler(response)
            if let e = error as NSError? {
                errorHandler(e)
                errorDataHandler(data)
            } else if let httpResponse = response as? HTTPURLResponse {
                httpResponseHandler(httpResponse)
                if httpResponse.statusCode > 299, let data = data {
                    errorDataHandler(data)
                    serverErrorHandler(NSError(domain: "Server", code: httpResponse.statusCode, userInfo: ["url" : httpResponse.url?.absoluteString as Any]))
                } else {
                    dataHandler(data)
                }
            }
            session.finishTasksAndInvalidate()
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

public func applyBody(_ postData: Data?, request: NSMutableURLRequest) {
    request.httpBody = postData
}
