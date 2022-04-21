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
    
    static func loginCall(_ signIn: SignIn, modelHandler: @escaping (AuthResponse?) -> Void) -> NetworkCall {
        var endpoint = Endpoint()
        addJsonHeaders(&endpoint)
        endpoint.path = "sessions"
        endpoint.httpMethod = "POST"
        return call(from: endpoint, modelHandler)
    }
    
    static func createArticleCall(_ article: Article, modelHandler: @escaping (Article?) -> Void) -> NetworkCall {
        return call(from: createModelEndpoint(path: "articles", article), modelHandler)
    }
    
    static func getPageOfArticlesCall(_ page: Int, _ modelHandler: @escaping ([Article]?) -> Void) -> NetworkCall {
        var endpoint = getModelEndpoint(path: "articles")
        endpoint.getParams = [URLQueryItem(name: "page", value: "\(page)")]
        return call(from: endpoint, modelHandler)
    }
    
    static func call<T>(from endpoint: Endpoint, _ modelHandler: @escaping (T?) -> Void) -> NetworkCall where T: Decodable {
        let responder = parsingNetworkResponder(modelHandler)
        return NetworkCall(configuration: serverConfig, endpoint: endpoint, responder: responder)
    }
}

class AuthResponse: Decodable {
    var token: String?
}

class Article: Codable {}

public func authorize(_ endpoint: inout Endpoint) {
    endpoint.addHeaders(headers: ["X-Api-Key" : ""])
}

public func createModelEndpoint<T>(path: String, _ model: T) -> Endpoint where T: Encodable {
    var endpoint = Endpoint()
    endpoint.path = path
    endpoint.httpMethod = "POST"
    endpoint.postData = try? JSONEncoder().encode(model)
    addJsonHeaders(&endpoint)
    authorize(&endpoint)
    return endpoint
}

public func editModelEndpoint<T>(path: String, _ model: T) -> Endpoint where T: Encodable {
    var endpoint = Endpoint()
    endpoint.path = path
    endpoint.httpMethod = "PUT"
    endpoint.postData = try? JSONEncoder().encode(model)
    addJsonHeaders(&endpoint)
    authorize(&endpoint)
    return endpoint
}

public func getModelEndpoint(path: String) -> Endpoint {
    var endpoint = Endpoint()
    endpoint.path = path
    addJsonHeaders(&endpoint)
    authorize(&endpoint)
    return endpoint
}

public func getModelsEndpoint(path: String) -> Endpoint {
    var endpoint = Endpoint()
    endpoint.path = path
    addJsonHeaders(&endpoint)
    authorize(&endpoint)
    return endpoint
}

public func parsingNetworkResponder<T>(_ modelHandler: @escaping (T?) -> Void) -> NetworkResponder where T: Decodable {
    let responder = NetworkResponder()
    responder.dataHandler = dataParser(from: modelHandler)
    return responder
}

public func dataParser<T>(from modelHandler: @escaping (T?) -> Void) -> (Data?) -> Void where T: Decodable {
    return ~>(parseDataToModel >>> modelHandler)
}

public func parseDataToModel<T>(_ data: Data) -> T? where T: Decodable {
    return try? JSONDecoder().decode(T.self, from: data)
}

