//
//  ServerConfiguration.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import LithoOperators
import Foundation

open class ServerConfiguration {
    public let shouldStub: Bool
    public let shouldUseCookies: Bool
    public let scheme: String
    public let host: String
    public let apiBaseRoute: String?
    public var urlConfiguration: URLSessionConfiguration

    public init(shouldStub: Bool = false, shouldUseCookies: Bool = false, scheme: String = "https", host: String, apiRoute: String?, urlConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.shouldStub = shouldStub
        self.shouldUseCookies = shouldUseCookies
        self.scheme = scheme
        self.host = host
        self.apiBaseRoute = apiRoute
        self.urlConfiguration = urlConfiguration
    }
    
    public func toBaseURL() -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        if let baseRoute = apiBaseRoute {
            if baseRoute.starts(with: "/") {
                urlComponents.path = baseRoute
            } else {
                urlComponents.path = "/\(baseRoute)"
            }
        }
        return urlComponents
    }
    
    public func url(for endpoint: Endpoint) -> URL? {
        return toBaseURL().url(for: endpoint)
    }
    
    public func request(for endpoint: Endpoint) -> URLRequest? {
        return generateRequest(from: self, endpoint: endpoint)
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
}
