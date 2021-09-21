//
//  ErrorData.swift
//  FunNet
//
//  Created by Elliot Schrock on 9/8/21.
//

import Foundation
import LithoOperators
import LithoUtils
import Prelude
import Slippers

public protocol FunNetErrorData: Codable {
    var message: String? { get set }
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

public func dataHandler(vc: UIViewController?) -> (Data?) -> Void {
    return (dataToString >?> ("Error" *-> alert)) >?> vc?.presentClosure()
}
