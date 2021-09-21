//
//  ErrorDebugging.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Foundation
import LithoOperators
import LithoUtils
import Prelude
import Slippers

// MARK: - Handle errors

public func debugLoadingErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return (errorMap -*> debugErrorAlert -*> ifExecute) >?> vc?.presentClosure()
}

public func debugServerErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return debugServerErrorHandler(presenter: vc?.presentClosure(), errorMap: errorMap)
}

// MARK: - Handle errors from response/data

public func debugURLResponseHandler(vc: UIViewController?) -> (HTTPURLResponse?) -> Void {
    return debugURLResponseHandler(presenter: vc?.presentClosure())
}

public func debugFunNetErrorDataResponseHandler<T: FunNetErrorData>(vc: UIViewController?, type: T.Type) -> (HTTPURLResponse?, Data?) -> Void {
    return debugFunNetErrorDataResponseHandler(presenter: vc?.presentClosure(), type: type)
}

// MARK: - supporting functions

public func debugLoadingErrorHandler(vc: UIViewController?) -> (NSError?) -> Void {
    return debugLoadingErrorHandler(presenter: vc?.presentClosure())
}

public func debugLoadingErrorHandler(presenter: ((UIViewController) -> Void)?, errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return (errorMap -*> debugErrorAlert -*> ifExecute) >?> presenter
}

public func debugServerErrorHandler(presenter: ((UIViewController) -> Void)?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorMap -*> debugErrorAlert -*> ifExecute) >?> presenter
}

public func debugURLResponseHandler(presenter: ((UIViewController) -> Void)?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (errorMap -*> debugResponseAlert -*> ifExecute) >?> presenter
}

public func debugFunNetErrorDataResponseHandler<T: FunNetErrorData>(presenter: ((UIViewController) -> Void)?, type: T.Type) -> (HTTPURLResponse?, Data?) -> Void {
    let statusCode = ^\HTTPURLResponse.statusCode -*> ifExecute
    let error = (type *-> JsonProvider.decode) -*> ifExecute
    let codeAndError = tupleMap(statusCode, error)
    return codeAndError >>> ~debugFunNetErrorDataAlert >?> presenter
}
