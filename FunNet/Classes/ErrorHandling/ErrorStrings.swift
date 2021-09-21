//
//  ErrorStrings.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Foundation
import LithoOperators
import LithoUtils
import Prelude
import Slippers

public func statusAndFunNetErrorDataToString(code: Int?, error: FunNetErrorData?) -> String {
    return "Error: \(code != nil ? "\(code!)" : "") \(error?.message ?? "")"
}
public func responseAndFunNetworkErrorToString(response: HTTPURLResponse?, error: FunNetErrorData?) -> String {
    return "Error: \(response != nil ? "\(response!.statusCode)" : ""), \(error?.message ?? "")"
}

public let errorCodeToErrorTitle: (Int) -> String = { "Error \($0)" }

public let dataToString: (Data?) -> String? = { data in
    guard let data = data else { return nil }
    return String(data: data, encoding: .utf8)
}
public func errorString(messageMap: [Int: String]) -> (NSError) -> String {
    return (^\NSError.code) >>> fzip({ "Error \($0): " }, keyToValue(for: messageMap) >>> coalesceNil(with: "unknown.")) >>> { $0.0 + $0.1 }
}
public func responseString(messageMap: [Int: String]) -> (HTTPURLResponse) -> String {
    return (^\.statusCode) >>> fzip({ "Error: \($0), " }, keyToValue(for: messageMap) >>> coalesceNil(with: "unknown.")) >>> { $0.0 + $0.1 }
}
