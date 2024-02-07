//
//  AsyncNetworkCall.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/4/24.
//

import Foundation

open class AsyncNetworkCall: AsyncFireable {
    var sessionizer: Sessionizer
    public var baseUrl: URLComponents
    public var endpoint: Endpoint
    
    public var requestLogLevel: FunNetRequestLogLevel = .none
    
    public var reset: (AsyncNetworkCall) -> Void = { _ in }
    public var firingFunc: (AsyncNetworkCall) async throws -> Data = fire(_:)
    
    public init(configuration: ServerConfiguration, endpoint: Endpoint) {
        self.baseUrl = configuration.toBaseURL()
        self.sessionizer = .config(configuration.urlConfiguration)
        self.endpoint = endpoint
    }
    
    public init(session: URLSession, baseUrlComponents: URLComponents, endpoint: Endpoint) {
        self.baseUrl = baseUrlComponents
        self.sessionizer = .session(session)
        self.endpoint = endpoint
    }
    
    public init(sessionConfig: URLSessionConfiguration, baseUrlComponents: URLComponents, endpoint: Endpoint) {
        self.baseUrl = baseUrlComponents
        self.sessionizer = .config(sessionConfig)
        self.endpoint = endpoint
    }
    
    open func fire() async throws -> Data? {
        try await firingFunc(self)
    }
    
    open func resetAndFire() async throws -> Data? {
        reset(self)
        return try await firingFunc(self)
    }
}

public func defaultJsonDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}

public class ParsingNetworkCall<T>: AsyncNetworkCall where T: Codable {
    var parser: (Data) -> T?
    
    public init(configuration: ServerConfiguration, endpoint: Endpoint, parser: @escaping (Data) -> T? = { try? defaultJsonDecoder().decode(T.self, from: $0) }) {
        self.parser = parser
        super.init(configuration: configuration, endpoint: endpoint)
    }
    
    public init(session: URLSession, baseUrlComponents: URLComponents, endpoint: Endpoint, parser: @escaping (Data) -> T? = { try? defaultJsonDecoder().decode(T.self, from: $0) }) {
        self.parser = parser
        super.init(session: session, baseUrlComponents: baseUrlComponents, endpoint: endpoint)
    }
    
    public init(sessionConfig: URLSessionConfiguration, baseUrlComponents: URLComponents, endpoint: Endpoint, parser: @escaping (Data) -> T? = { try? defaultJsonDecoder().decode(T.self, from: $0) }) {
        self.parser = parser
        super.init(sessionConfig: sessionConfig, baseUrlComponents: baseUrlComponents, endpoint: endpoint)
    }
    
    public func fireAndParse() async throws -> T? {
        if let data = try await fire() {
            return parser(data)
        }
        return nil
    }
}

public func fire(_ call: AsyncNetworkCall) async throws -> Data {
    let request = generateRequest(from: call.baseUrl, endpoint: call.endpoint, logLevel: call.requestLogLevel)
    
    if let request = request {
        let (data, response): (Data, URLResponse)
        switch call.sessionizer {
        case .config(let sessionConfig):
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
            (data, response) = try await session.data(for: request)
        case .session(let session):
            (data, response) = try await session.data(for: request)
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode > 299 {
                var info: [String: Any] = ["url" : httpResponse.url?.absoluteString as Any]
                
                if let stringData = String(data: data, encoding: .utf8) {
                    info["data"] = stringData
                }
                
                throw NSError(domain: "Server", code: httpResponse.statusCode, userInfo: info)
            }
        }
        
        return data
    } else {
        throw NSError(domain: "URL Request", code: -422, userInfo: ["message": "URLRequest is nil"])
    }
}
