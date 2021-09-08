//
//  ErrorCombine.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Combine
import LithoOperators
import Prelude

public func dataTaskCompletionError(completion: Subscribers.Completion<URLError>) -> URLError? {
    switch completion {
    case .finished:
        return nil
    case .failure(let error):
        return error
    }
}

public let printTaskError = dataTaskCompletionError >?> ^\URLError.errorCode >>> fzip(errorCodeToErrorTitle, keyToValue(for: urlLoadingErrorCodesDict)) >>> printTwoStrings
public func debugTaskErrorAlerter(errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> UIAlertController? {
    return dataTaskCompletionError >?> ^\URLError.errorCode >>> (errorMap -*> debugAlert(code:errorMap:))
}
public func prodTaskErrorAlerter(errorMap: [Int: String] = urlLoadingErrorCodesDict) -> (Subscribers.Completion<URLError>) -> UIAlertController? {
    return dataTaskCompletionError >?> ^\URLError.errorCode >>> (errorMap -*> prodAlert(code:errorMap:))
}
