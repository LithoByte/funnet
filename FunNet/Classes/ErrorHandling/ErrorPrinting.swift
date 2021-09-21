//
//  ErrorPrinting.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Foundation
import LithoOperators
import LithoUtils
import Prelude
import Slippers

public let printStr: (String?) -> Void = { print($0) } -*> ifExecute
public let printTwoStrings: (String?, String?) -> Void = { print($0! as Any, $1! as Any) }

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
