//
//  ErrorURLSession.swift
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

public typealias URLSessionHandler = (NSError?, HTTPURLResponse?, Data?) -> Void

public let printingLoadingErrorSessionHandler: ([Int:String]) -> URLSessionHandler = printingLoadingErrorHandler >>> ignoreIrrelevantArgs
public let printingHttpResponseSessionHandler: ([Int:String]) -> URLSessionHandler = printingHttpResponseErrorHandler >>> ignoreIrrelevantArgs
public let printingServerErrorSessionHandler: ([Int:String]) -> URLSessionHandler = printingServerErrorHandler >>> ignoreIrrelevantArgs
public let debugLoadingErrorSessionHandler: (UIViewController?) -> URLSessionHandler = debugLoadingErrorHandler >>> ignoreIrrelevantArgs
public let prodLoadingErrorSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = prodLoadingErrorHandler >>> ignoreIrrelevantArgs
public let debugResponseSessionHandler: (UIViewController?) -> URLSessionHandler = debugURLResponseHandler >>> ignoreIrrelevantArgs
public let prodResponseSessionHandler: (UIViewController?, [Int:String]) -> URLSessionHandler = prodURLResponseHandler >>> ignoreIrrelevantArgs
public func debugFunNetErrorDataSessionHandler<T: FunNetErrorData>(_ vc: UIViewController?, type: T.Type) -> URLSessionHandler {
    return ignoreIrrelevantArgs(f: debugFunNetErrorDataResponseHandler(vc: vc, type: type))
}
public func prodFunNetErrorDataSessionHandler<T: FunNetErrorData>(_ vc: UIViewController?, type: T.Type) -> URLSessionHandler {
    return ignoreIrrelevantArgs(f: prodFunNetErrorDataResponseHandler(vc: vc, type: type))
}
