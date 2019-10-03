//
//  ServerConfiguration.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import UIKit

public protocol ServerConfigurationProtocol {
    var shouldStub: Bool { get }
    var scheme: String { get }
    var host: String { get }
    var apiBaseRoute: String? { get }
    var urlConfiguration: URLSessionConfiguration { get set }
}

open class ServerConfiguration: ServerConfigurationProtocol {
    public let shouldStub: Bool
    public let scheme: String
    public let host: String
    public let apiBaseRoute: String?
    public var urlConfiguration: URLSessionConfiguration

    public init(shouldStub: Bool = false, scheme: String = "https", host: String, apiRoute: String?, urlConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.shouldStub = shouldStub
        self.scheme = scheme
        self.host = host
        self.apiBaseRoute = apiRoute
        self.urlConfiguration = urlConfiguration
    }
}

public extension ServerConfigurationProtocol {
    func toBaseUrlString() -> String {
        let baseUrlString = "\(scheme)://\(host)"
        if let apiRoute = apiBaseRoute {
            return "\(baseUrlString)/\(apiRoute)/"
        } else {
            return "\(baseUrlString)/"
        }
    }
    
    func urlString(for endpoint: EndpointProtocol) -> String {
        return urlString(for: endpoint.path, getParams: endpoint.getParams)
    }
    
    func urlString(for endpointString: String, getParams: [String: Any]) -> String {
        if getParams.keys.count > 0 {
            return toBaseUrlString() + endpointString + "?\(dictionaryToUrlParams(dict: getParams))"
        }
        return toBaseUrlString() + endpointString
    }
}

public func dictionaryToUrlParams(dict: [String: Any]) -> String {
    var params = [String]()
    for key in dict.keys {
        if let value: Any = dict[key] {
            var valueString = "\(String(describing: value))"
            if let valueArray = value as? [AnyObject] {
                valueString = valueArray.map { "\($0)" }.joined(separator: ",")
            }
            let param = "\(key)=\(valueString)"
            params.append(param)
        }
    }
    return params.joined(separator: "&")
}
