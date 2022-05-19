//
//  URLSessionExtensions.swift
//  FunNet
//
//  Created by Elliot on 4/19/22.
//

import Foundation
import Combine
import LithoOperators

extension URLSessionDataTask: Fireable {
    public func fire() {
        resume()
    }
}

public extension URLRequest {
    var method: HttpMethod? {
        get { httpMethod ?> HttpMethod.init(rawValue:) }
        set { httpMethod = newValue?.rawValue }
    }
    
    mutating func configure(from endpoint: Endpoint) {
        for key in endpoint.httpHeaders.keys {
            self.addValue(endpoint.httpHeaders[key]!, forHTTPHeaderField: key)
        }
        self.httpMethod = endpoint.httpMethod
        self.httpBody = endpoint.postData
        if let stream = endpoint.dataStream {
            self.httpBodyStream = stream
        }
        self.timeoutInterval = endpoint.timeout
    }
    
    mutating func addHeaders(_ headers: [String: String]) {
        for key in headers.keys {
            self.addValue(headers[key]!, forHTTPHeaderField: key)
        }
    }
}

public extension URLComponents {
    func url(for endpoint: Endpoint) -> URL? {
        var copy = self
        if !endpoint.getParams.isEmpty {
            copy.queryItems = endpoint.getParams
        }
        return copy.url?.appendingPathComponent(endpoint.path)
    }
    
    func request(for endpoint: Endpoint) -> URLRequest? {
        return generateRequest(from: self, endpoint: endpoint)
    }
    
    func url(for path: String, getParams: [URLQueryItem] = []) -> URL? {
        var copy = self
        if !getParams.isEmpty {
            copy.queryItems = getParams
        }
        return copy.url?.appendingPathComponent(path)
    }
}
