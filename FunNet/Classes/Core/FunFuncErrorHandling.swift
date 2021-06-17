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

public protocol FunNetworkError: Codable {
    var message: String? { get set }
}

public func printingLoadingErrorHandler(errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return ((errorString(messageMap: errorMap) >>> coalesceNil(with: "")) >||> ifExecute) >?> printStr
}

public func printingHttpResponseErrorHandler(errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (responseString(messageMap: errorMap) >>> coalesceNil(with: "") >||> ifExecute) >?> printStr
}

public func printingServerErrorHandler(errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorString(messageMap: errorMap) >>> coalesceNil(with: "") >||> ifExecute) >?> printStr
}

public func printingErrorDataHandler<T: FunNetworkError>(type: T.Type) -> (Data?) -> Void {
    return (type >|> JsonProvider.decode) >||> ifExecute >?> ^\.message >?> printStr
}

public let printingErrorDataHandler: (Data?) -> Void = (.utf8 >||> String.init(data:encoding:)) >||> ifExecute >?> printStr

public func printingFunNetworkErrorHandler<T: FunNetworkError>(type: T.Type) -> (HTTPURLResponse?, Data?) -> Void {
    let errorString: ((Int?, T?)) -> String = ~statusAndFunNetworkErrorToString(code:error:)
    let statusCode = ^\HTTPURLResponse.statusCode >||> ifExecute
    let decoder = (type >|> JsonProvider.decode) >||> ifExecute
    let codeAndFunNetError = tupleMap(statusCode, decoder)
    return codeAndFunNetError >>> errorString >>> printStr
}

public func debugLoadingErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return (errorMap >||> debugErrorAlert >||> ifExecute) >?> vc?.presentClosure()
}

public func debugServerErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorMap >||> debugErrorAlert >||> ifExecute) >?> vc?.presentClosure()
}

public func debugURLResponseHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (errorMap >||> debugResponseAlert >||> ifExecute) >?> vc?.presentClosure()
}

public func debugFunNetworkErrorResponseHandler<T: FunNetworkError>(vc: UIViewController?, type: T.Type) -> (HTTPURLResponse?, Data?) -> Void {
    let statusCode = ^\HTTPURLResponse.statusCode >||> ifExecute
    let error = (type >|> JsonProvider.decode) >||> ifExecute
    let codeAndError = tupleMap(statusCode, error)
    return codeAndError >>> ~debugFunNetworkErrorAlert >?> vc?.presentClosure()
}

public func prodLoadingErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return (errorMap >||> prodErrorAlert >||> ifExecute) >?> vc?.presentClosure()
}

public func prodServerErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorMap >||> prodErrorAlert >||> ifExecute) >?> vc?.presentClosure()
}

public func prodURLResponseHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (errorMap >||> prodResponseAlert >||> ifExecute) >?> vc?.presentClosure()
}

public func prodFunNetworkErrorResponseHandler<T: FunNetworkError>(vc: UIViewController?, type: T.Type) -> (Data?) -> Void {
    return (type >|> JsonProvider.decode) >||> ifExecute >>> prodFunNetworkErrorAlert >?> vc?.presentClosure()
}

public func dataHandler(vc: UIViewController?) -> (Data?) -> Void {
    return (dataToString >?> ("Error" >||> alert)) >?> vc?.presentClosure()
}

public typealias URLSessionHandler = (NSError?, HTTPURLResponse?, Data?) -> Void

public let printingLoadingErrorSessionHandler: ([Int:String]) -> URLSessionHandler = printingLoadingErrorHandler >>> ignoreIrrelevantArgs
public let printingHttpResponseSessionHandler: ([Int:String]) -> URLSessionHandler = printingHttpResponseErrorHandler >>> ignoreIrrelevantArgs
public let printingServerErrorSessionHandler: ([Int:String]) -> URLSessionHandler = printingServerErrorHandler >>> ignoreIrrelevantArgs
public let debugLoadingErrorSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = debugLoadingErrorHandler >>> ignoreIrrelevantArgs
public let prodLoadingErrorSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = prodLoadingErrorHandler >>> ignoreIrrelevantArgs
public let debugResponseSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = debugURLResponseHandler >>> ignoreIrrelevantArgs
public let prodResponseSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = prodURLResponseHandler >>> ignoreIrrelevantArgs
public func debugFunNetworkErrorSessionHandler<T: FunNetworkError>(_ vc: UIViewController?, type: T.Type) -> URLSessionHandler {
    return ignoreIrrelevantArgs(f: debugFunNetworkErrorResponseHandler(vc: vc, type: type))
}
public func prodFunNetworkErrorSessionHandler<T: FunNetworkError>(_ vc: UIViewController?, type: T.Type) -> URLSessionHandler {
    return ignoreIrrelevantArgs(f: prodFunNetworkErrorResponseHandler(vc: vc, type: type))
}


//MARK: - Alert Functions

public func debugAlert(code: Int, errorMap: [Int:String]) -> UIAlertController {
    return alert("Error: \(code)", errorMap[code] ?? "")
}
public func prodAlert(code: Int, errorMap: [Int:String]) -> UIAlertController {
    return alert("Something went wrong!", errorMap[code] ?? "")
}
public func debugFunNetworkErrorAlert(code: Int?, error: FunNetworkError?) -> UIAlertController? {
    return alert("Error\(code == nil ? "" : ": \(code!)")", error?.message ?? "")
}
public func prodFunNetworkErrorAlert(error: FunNetworkError?) -> UIAlertController? {
    return alert("Something went wrong!", error?.message ?? "")
}

public let debugErrorAlert: (NSError, [Int:String]) -> UIAlertController = (^\.code) >*> debugAlert
public let prodErrorAlert: (NSError, [Int:String]) -> UIAlertController = (^\.code) >*> prodAlert
public let debugResponseAlert: (HTTPURLResponse, [Int:String]) -> UIAlertController = (^\.statusCode) >*> debugAlert
public let prodResponseAlert: (HTTPURLResponse, [Int:String]) -> UIAlertController = (^\.statusCode) >*> prodAlert

public func statusAndFunNetworkErrorToString(code: Int?, error: FunNetworkError?) -> String {
    return "Error: \(code != nil ? "\(code!)" : "") \(error?.message ?? "")"
}
public func responseAndFunNetworkErrorToString(response: HTTPURLResponse?, error: FunNetworkError?) -> String {
    return "Error: \(response == nil ? "\(response!.statusCode)" : ""), \(error?.message ?? "")"
}

public let dataToString: (Data?) -> String? = { data in
    guard let data = data else { return nil }
    return String(data: data, encoding: .utf8)
}
public func errorString(messageMap: [Int:String]) -> (NSError) -> String {
    return (^\NSError.code) >>> fzip({ "Error: \($0), " }, get(dict: messageMap) >>> coalesceNil(with: "")) >>> { $0.0 + $0.1 }
}
public func responseString(messageMap: [Int:String]) -> (HTTPURLResponse) -> String {
    return (^\.statusCode) >>> fzip({ "Error: \($0), " }, get(dict: messageMap) >>> coalesceNil(with: "")) >>> { $0.0 + $0.1 }
}

public let printStr: (String?) -> Void = { print($0) } >||> ifExecute
