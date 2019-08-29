//
//  Api.swift
//  FunNet_Example
//
//  Created by Elliot Schrock on 2/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import FunNet
import Prelude

class Api {
    static let serverConfig = ServerConfiguration(host: "fake.com", apiRoute: "api/v1")
    
    static func loginCall(_ signIn: SignIn, modelHandler: @escaping (AuthResponse?) -> Void) -> FunNetCall {
        var endpoint = dataEndpoint(with: signIn)
        endpoint.path = "sessions"
        endpoint /> setToPost
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

public func authorize<T>(_ endpoint: inout T) where T: EndpointProtocol {
    endpoint.addHeaders(headers: ["X-Api-Key" : ""])
}

public func createModelEndpoint<T>(path: String, _ model: T) -> Endpoint where T: Encodable {
    var endpoint = dataEndpoint(with: model)
    endpoint.path = path
    endpoint /> (setToPost <~> authorize)
    return endpoint
}

public func editModelEndpoint<T>(path: String, _ model: T) -> Endpoint where T: Encodable {
    var endpoint = dataEndpoint(with: model)
    endpoint.path = path
    endpoint /> setToPut
    return endpoint
}

public func getModelEndpoint(path: String) -> Endpoint {
    var endpoint = Endpoint()
    endpoint.path = path
    endpoint /> (addJsonHeaders <~> authorize)
    return endpoint
}

public func getModelsEndpoint(path: String) -> EndpointProtocol {
    var endpoint = Endpoint()
    endpoint.path = path
    endpoint /> (addJsonHeaders <~> authorize)
    return endpoint
}

public func urlParamModelsEndpoint(path: String, params: [String: Any]) -> EndpointProtocol {
    return getModelsEndpoint(path: "\(path)?\(dictionaryToUrlParams(dict: params))")
}

public func dataEndpoint<T>(with model: T) -> Endpoint where T: Encodable {
    return dataSetEndpoint(from: dataSetter(from: model))
}

public func dataSetEndpoint(from dataSetter: @escaping (inout Endpoint) -> Void) -> Endpoint {
    var endpoint = Endpoint()
    endpoint /> (addJsonHeaders <~> dataSetter)
    return endpoint
}

public func parsingNetworkResponder<T>(_ modelHandler: @escaping (T?) -> Void) -> NetworkResponder where T: Decodable {
    var responder = NetworkResponder()
    responder.dataHandler = dataParser(from: modelHandler)
    return responder
}

public func dataParser<T>(from modelHandler: @escaping (T?) -> Void) -> (Data?) -> Void where T: Decodable {
    return (parseDataToModel >>> modelHandler) |> skipNil
}

public func skipNil<T>(_ f: @escaping (T) -> Void) -> (T?) -> Void {
    return { a in
        if let unwrapped = a {
            f(unwrapped)
        }
    }
}

public func parseDataToModel<T>(_ data: Data) -> T? where T: Decodable {
    return try? JSONDecoder().decode(T.self, from: data)
}

public func identity<T>(value: T?) -> T? {
    return value
}

