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

public protocol FunNetErrorData: Codable {
    var message: String? { get set }
}

public func printingLoadingErrorHandler(errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return ((errorString(messageMap: errorMap) >>> coalesceNil(with: "Unknown Error")) -*> ifExecute) >?> printStr
}

public func printingHttpResponseErrorHandler(errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (responseString(messageMap: errorMap) >>> coalesceNil(with: "Unknown Error") -*> ifExecute) >?> printStr
}

public func printingServerErrorHandler(errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorString(messageMap: errorMap) >>> coalesceNil(with: "Unknown Error") -*> ifExecute) >?> printStr
}

public func printingErrorDataHandler<T: FunNetErrorData>(type: T.Type) -> (Data?) -> Void {
    return (type *-> JsonProvider.decode) -*> ifExecute >?> ^\.message >?> printStr
}

public let printingErrorDataHandler: (Data?) -> Void = (.utf8 -*> String.init(data:encoding:)) -*> ifExecute >?> printStr

public func printingFunNetErrorDataHandler<T: FunNetErrorData>(type: T.Type) -> (HTTPURLResponse?, Data?) -> Void {
    let errorString: ((Int?, T?)) -> String = ~statusAndFunNetErrorDataToString(code:error:)
    let statusCode = ^\HTTPURLResponse.statusCode -*> ifExecute
    let decoder = (type *-> JsonProvider.decode) -*> ifExecute
    let codeAndFunNetError = tupleMap(statusCode, decoder)
    return codeAndFunNetError >>> errorString >>> printStr
}

public func responseToFunNetErrorData<T: FunNetErrorData>(type: T.Type) -> (URLResponse?, Data?) -> (Int?, T?) {
    let statusCode: (URLResponse?) -> Int? = ~>(^\HTTPURLResponse.statusCode) -*> ifExecute
    let decoder = (type *-> JsonProvider.decode) -*> ifExecute
    return tupleMap(statusCode, decoder)
}

public func httpResponseToFunNetErrorData<T: FunNetErrorData>(type: T.Type) -> (HTTPURLResponse?, Data?) -> (Int?, T?) {
    let statusCode = ^\HTTPURLResponse.statusCode -*> ifExecute
    let decoder = (type *-> JsonProvider.decode) -*> ifExecute
    return tupleMap(statusCode, decoder)
}

public func debugLoadingErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return (errorMap -*> debugErrorAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func debugServerErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorMap -*> debugErrorAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func debugURLResponseHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (errorMap -*> debugResponseAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func debugFunNetErrorDataResponseHandler<T: FunNetErrorData>(vc: UIViewController?, type: T.Type) -> (HTTPURLResponse?, Data?) -> Void {
    let statusCode = ^\HTTPURLResponse.statusCode -*> ifExecute
    let error = (type *-> JsonProvider.decode) -*> ifExecute
    let codeAndError = tupleMap(statusCode, error)
    return codeAndError >>> ~debugFunNetErrorDataAlert >?> vc?.presentClosure()
}

public func prodLoadingErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return (errorMap -*> prodErrorAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func prodServerErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorMap -*> prodErrorAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func prodURLResponseHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (errorMap -*> prodResponseAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func prodFunNetErrorDataResponseHandler<T: FunNetErrorData>(vc: UIViewController?, type: T.Type) -> (Data?) -> Void {
    return (type *-> JsonProvider.decode) -*> ifExecute >>> prodFunNetErrorDataAlert >?> vc?.presentClosure()
}

public func dataHandler(vc: UIViewController?) -> (Data?) -> Void {
    return (dataToString >?> ("Error" -*> alert)) >?> vc?.presentClosure()
}

public typealias URLSessionHandler = (NSError?, HTTPURLResponse?, Data?) -> Void

public let printingLoadingErrorSessionHandler: ([Int:String]) -> URLSessionHandler = printingLoadingErrorHandler >>> ignoreIrrelevantArgs
public let printingHttpResponseSessionHandler: ([Int:String]) -> URLSessionHandler = printingHttpResponseErrorHandler >>> ignoreIrrelevantArgs
public let printingServerErrorSessionHandler: ([Int:String]) -> URLSessionHandler = printingServerErrorHandler >>> ignoreIrrelevantArgs
public let debugLoadingErrorSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = debugLoadingErrorHandler >>> ignoreIrrelevantArgs
public let prodLoadingErrorSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = prodLoadingErrorHandler >>> ignoreIrrelevantArgs
public let debugResponseSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = debugURLResponseHandler >>> ignoreIrrelevantArgs
public let prodResponseSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = prodURLResponseHandler >>> ignoreIrrelevantArgs
public func debugFunNetErrorDataSessionHandler<T: FunNetErrorData>(_ vc: UIViewController?, type: T.Type) -> URLSessionHandler {
    return ignoreIrrelevantArgs(f: debugFunNetErrorDataResponseHandler(vc: vc, type: type))
}
public func prodFunNetErrorDataSessionHandler<T: FunNetErrorData>(_ vc: UIViewController?, type: T.Type) -> URLSessionHandler {
    return ignoreIrrelevantArgs(f: prodFunNetErrorDataResponseHandler(vc: vc, type: type))
}


//MARK: - Alert Functions

public func debugAlert(code: Int, errorMap: [Int:String]) -> UIAlertController {
    return alert("Error: \(code)", errorMap[code] ?? "")
}
public func prodAlert(code: Int, errorMap: [Int:String]) -> UIAlertController {
    return alert("Something went wrong!", errorMap[code] ?? "")
}
public func debugFunNetErrorDataAlert(code: Int?, error: FunNetErrorData?) -> UIAlertController? {
    return alert("Error\(code == nil ? "" : ": \(code!)")", error?.message ?? "")
}
public func prodFunNetErrorDataAlert(error: FunNetErrorData?) -> UIAlertController? {
    return alert("Something went wrong!", error?.message ?? "")
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

public func statusAndFunNetErrorDataToString(code: Int?, error: FunNetErrorData?) -> String {
    return "Error: \(code != nil ? "\(code!)" : "") \(error?.message ?? "")"
}
public func responseAndFunNetErrorDataToString(response: HTTPURLResponse?, error: FunNetErrorData?) -> String {
    return "Error: \(response == nil ? "\(response!.statusCode)" : ""), \(error?.message ?? "")"
}

public let dataToString: (Data?) -> String? = { data in
    guard let data = data else { return nil }
    return String(data: data, encoding: .utf8)
}
public func errorString(messageMap: [Int:String]) -> (NSError) -> String {
    return (^\NSError.code) >>> fzip({ "Error \($0): " }, keyToValue(for: messageMap) >>> coalesceNil(with: "unknown.")) >>> { $0.0 + $0.1 }
}
public func responseString(messageMap: [Int:String]) -> (HTTPURLResponse) -> String {
    return (^\.statusCode) >>> fzip({ "Error: \($0), " }, keyToValue(for: messageMap) >>> coalesceNil(with: "")) >>> { $0.0 + $0.1 }
}

public let printStr: (String?) -> Void = { print($0) } -*> ifExecute
