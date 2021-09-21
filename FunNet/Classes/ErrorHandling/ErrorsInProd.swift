//
//  ErrorsInProd.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Foundation
import LithoOperators
import LithoUtils
import Prelude
import Slippers

public func prodLoadingErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    return prodLoadingErrorHandler(presenter: vc?.presentClosure(), errorMap: errorMap)
}

public func prodLoadingErrorHandler(presenter: ((UIViewController) -> Void)?, errorMap: [Int:String] = urlLoadingErrorCodesDict) -> (NSError?) -> Void {
    (errorMap -*> prodErrorAlert -*> ifExecute) >?> presenter
}

public func prodServerErrorHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return prodServerErrorHandler(presenter: vc?.presentClosure(), errorMap: errorMap)
}

public func prodServerErrorHandler(presenter: ((UIViewController) -> Void)?, errorMap: [Int:String] = urlResponseErrorMessages) -> (NSError?) -> Void {
    return (errorMap -*> prodErrorAlert -*> ifExecute) >?> presenter
}

public func prodURLResponseHandler(vc: UIViewController?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return prodURLResponseHandler(presenter: vc?.presentClosure(), errorMap: errorMap)
}

public func prodURLResponseHandler(presenter: ((UIViewController) -> Void)?, errorMap: [Int:String] = urlResponseErrorMessages) -> (HTTPURLResponse?) -> Void {
    return (errorMap -*> prodResponseAlert -*> ifExecute) >?> presenter
}

public func prodFunNetErrorDataResponseHandler<T: FunNetErrorData>(vc: UIViewController?, type: T.Type) -> (Data?) -> Void {
    return prodFunNetErrorDataResponseHandler(presenter: vc?.presentClosure(), type: type)
}

public func prodFunNetErrorDataResponseHandler<T: FunNetErrorData>(presenter: ((UIViewController) -> Void)?, type: T.Type) -> (Data?) -> Void {
    return (type *-> JsonProvider.decode) -*> ifExecute >>> prodFunNetErrorDataAlert >?> presenter
}
