//
//  ErrorAlerts.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Foundation
import LithoOperators
import LithoUtils
import Prelude
import Slippers
import UIKit

public func debugAlert(code: Int, errorMap: [Int: String]) -> UIAlertController {
    return alert("Error: \(code)", errorMap[code] ?? "")
}
public func prodAlert(code: Int, errorMap: [Int:String]) -> UIAlertController {
    return alert("Something went wrong!", errorMap[code] ?? "")
}
public func debugFunNetErrorDataAlert(code: Int?, error: FunNetErrorData?) -> UIAlertController? {
    return codeStringAlert(code: code, description: error?.message)
}
public func prodFunNetErrorDataAlert(error: FunNetErrorData?) -> UIAlertController? {
    if let err = error {
        return alert("Something went wrong!", err.message ?? "")
    }
    return nil
}
public func codeStringAlert(code: Int?, description: String?) -> UIAlertController? {
    if let code = code, let desc = description {
        return alert("Error \(code)", desc)
    } else {
        return nil
    }
}

public let debugErrorAlert: (NSError, [Int:String]) -> UIAlertController = ^\.code >*-> debugAlert
public let prodErrorAlert: (NSError, [Int:String]) -> UIAlertController = ^\.code >*-> prodAlert
public let debugResponseAlert: (HTTPURLResponse, [Int:String]) -> UIAlertController = ^\.statusCode >*-> debugAlert
public let prodResponseAlert: (HTTPURLResponse, [Int:String]) -> UIAlertController = ^\.statusCode >*-> prodAlert
