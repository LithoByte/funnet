//
//  ErrorCombine.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Combine
import LithoOperators
import Prelude
import Foundation
import UIKit

#if canImport(Core)
    import Core
#endif

#if canImport(ErrorHandling)
    import ErrorHandling
#endif

public func dataTaskCompletionError(completion: Subscribers.Completion<URLError>) -> URLError? {
    switch completion {
    case .finished:
        return nil
    case .failure(let error):
        return error
    }
}

// MARK: - Handle Server Errors

public func prodServerResponseErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (URLSession.DataTaskPublisher.Output) -> Void {
    return responseToServerError() >>> prodServerErrorHandler(presenter: vc?.presentClosure(), errorMap: errorMap)
}

public func debugServerResponseErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (URLSession.DataTaskPublisher.Output) -> Void {
    return responseToServerError() >>> debugServerErrorHandler(presenter: vc?.presentClosure(), errorMap: errorMap)
}

// MARK: - Handle loading errors

public func debugTaskErrorAlerter(vc: UIViewController?, errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> Void {
    return debugTaskErrorAlerter(presenter: vc?.presentClosure(), errorMap: errorMap)
}
public func prodTaskErrorAlerter(vc: UIViewController?, errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> Void {
    return debugTaskErrorAlerter(presenter: vc?.presentClosure(), errorMap: errorMap)
}

public func debugTaskErrorAlerter(presenter: ((UIViewController) -> Void)?, errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> Void {
    return debugTaskErrorAlerter(errorMap: errorMap) >?> presenter
}
public func prodTaskErrorAlerter(presenter: ((UIViewController) -> Void)?, errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> Void {
    return prodTaskErrorAlerter(errorMap: errorMap) >?> presenter
}

public let printTaskError = dataTaskCompletionError >?> ^\URLError.errorCode >>> fzip(errorCodeToErrorTitle, keyToValue(for: urlLoadingErrorCodesDict)) >>> printTwoStrings
public func debugTaskErrorAlerter(errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> UIAlertController? {
    return dataTaskCompletionError >?> ^\URLError.errorCode >>> (errorMap -*> debugAlert(code:errorMap:))
}
public func prodTaskErrorAlerter(errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> UIAlertController? {
    return dataTaskCompletionError >?> ^\URLError.errorCode >>> (errorMap -*> prodAlert(code:errorMap:))
}
