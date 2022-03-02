//
//  Api.swift
//  FunNet_Example
//
//  Created by Elliot Schrock on 2/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import FunNet
import Prelude
import LithoOperators

class Api {
    static let serverConfig = ServerConfiguration(host: "fake.com", apiRoute: "api/v1")
    
    static func loginCall(_ signIn: SignIn, modelHandler: @escaping (AuthResponse?) -> Void) -> FunNetCall {
        var endpoint = Endpoint()
        endpoint.postData = try? JSONEncoder().encode(signIn)
        endpoint.path = "sessions"
        endpoint.httpMethod = "POST"
        return call(from: endpoint, modelHandler)
    }
    
    static func createArticleCall(_ article: Article, modelHandler: @escaping (Article?) -> Void) -> FunNetCall {
        return call(from: createModelEndpoint(path: "articles", article), modelHandler)
    }
    
    static func getPageOfArticlesCall(_ page: Int, _ modelHandler: @escaping ([Article]?) -> Void) -> FunNetCall {
        return call(from: urlParamModelsEndpoint(path: "articles", params: ["page": page]), modelHandler)
    }
    
    static func call<T>(from endpoint: EndpointProtocol, _ modelHandler: @escaping (T?) -> Void) -> FunNetCall where T: Decodable {
        let responder = parsingNetworkResponder(modelHandler)
        return FunNetCall(configuration: serverConfig, endpoint, responder: responder)
    }
}

class AuthResponse: Decodable {
    var token: String?
}

class Article: Codable {}

extension Endpoint {
    mutating func authorize() {
        self.addHeaders(headers: ["X-Api-Key" : ""])
    }
}

public func createModelEndpoint<T>(path: String, _ model: T) -> Endpoint where T: Encodable {
    var endpoint = Endpoint()
    endpoint.postData = try? JSONEncoder().encode(model)
    endpoint.path = path
    endpoint.httpMethod = "POST"
    endpoint.authorize()
    return endpoint
}

public func editModelEndpoint<T>(path: String, _ model: T) -> Endpoint where T: Encodable {
    var endpoint = dataSetEndpoint(from: dataSetter(from: model))
    endpoint.path = path
    endpoint.httpMethod = "PUT"
    return endpoint
}

public func getModelsEndpoint(path: String) -> EndpointProtocol {
    var endpoint = Endpoint()
    endpoint.path = path
    endpoint.authorize()
    addJsonHeaders(&endpoint)
    return endpoint
}

public func urlParamModelsEndpoint(path: String, params: [String: Any]) -> EndpointProtocol {
    return getModelsEndpoint(path: "\(path)?\(dictionaryToUrlParams(dict: params))")
}

public func dataSetEndpoint(from dataSetter: @escaping (inout Endpoint) -> Void) -> Endpoint {
    var endpoint = Endpoint()
    dataSetter(&endpoint)
    addJsonHeaders(&endpoint)
    return endpoint
}

public func parsingNetworkResponder<T>(_ modelHandler: @escaping (T?) -> Void) -> NetworkResponder where T: Decodable {
    var responder = NetworkResponder()
    responder.dataHandler = { data in
        guard let data = data, let model = try? JSONDecoder().decode(T.self, from: data)
        else { return }
        modelHandler(model)
    }
    return responder
}
