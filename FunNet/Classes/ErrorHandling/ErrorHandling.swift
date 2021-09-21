//
//  FunFuncErrorHandling.swift
//  FunNet
//
//  Created by Calvin Collins on 6/14/21.
//

import UIKit
import LithoOperators
import LithoUtils
import fuikit
import Prelude
import Slippers

//MARK: - Factories

func serverErrorHandlerFactory<T: FunNetErrorData>(presenter: UIViewController?, overrideCodes: [Int: String], unwrapper: @escaping (T) -> String? = ^\T.message) -> (NSError?) -> Void {
    return { e in
        if let error = e, error.domain == "Server" {
            if overrideCodes.keys.contains(error.code) {
                 error |> serverErrorHandlerMapOnlyFactory(presenter: presenter, overrideCodes: overrideCodes)
            } else {
                error |> serverErrorHandlerMessageFactory(presenter: presenter, overrideCodes: overrideCodes, unwrapper: unwrapper)
            }
        }
    }
}

func serverErrorHandlerMapOnlyFactory(presenter: UIViewController?, overrideCodes: [Int: String]) -> (NSError?) -> Void {
    return debugServerErrorHandler(vc: presenter, errorMap: urlResponseErrorMessages << overrideCodes)
}

func serverErrorHandlerMessageFactory<T: FunNetErrorData>(presenter: UIViewController?, overrideCodes: [Int: String], unwrapper: @escaping (T) -> String? = ^\T.message) -> (NSError?) -> Void {
    return { e in
        if let error = e, error.domain == "Server" {
            if let vc = presenter, let dataString = error.userInfo["data"] as? String, let data = dataString.data(using: .utf8), let responseError = JsonProvider.decode(T.self, from: data), let message = unwrapper(responseError) {
                codeStringAlert(code: error.code, description: message) ?> vc.presentClosure()
            } else {
                error |> debugServerErrorHandler(vc: presenter, errorMap: urlResponseErrorMessages << overrideCodes)
            }
        }
    }
}

infix operator <<: AdditionPrecedence
public func << <Key, Value>(_ lhs: [Key: Value], _ rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    for key in rhs.keys {
        result[key] = rhs[key]
    }
    return result
}
public func < <Key, Value>(_ lhs: [Key: Value], _ rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    for key in rhs.keys {
        if lhs[key] == nil {
            result[key] = rhs[key]
        }
    }
    return result
}
