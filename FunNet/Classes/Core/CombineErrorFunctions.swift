//
//  CombineErrorFunctions.swift
//  FunNet
//
//  Created by Calvin Collins on 5/13/21.
//

import Foundation
import Combine
import LithoOperators
import Prelude

@available(iOS 13.0, *)
public func bindError(from call: CombineNetCall, to handler: NetworkErrorFunctionProvider, storingIn cancelBag: inout Set<AnyCancellable>) {
    call.publisher.$error.compactMap(id).sink(receiveValue: handler.errorFunction()).store(in: &cancelBag)
}

@available(iOS 13.0, *)
public func bindErrorData(from call: CombineNetCall, to handler: NetworkErrorFunctionProvider, storingIn cancelBag: inout Set<AnyCancellable>) {
    call.publisher.$errorData.compactMap(id).sink(receiveValue: handler.dataFunction()).store(in: &cancelBag)
}

public func bindError<T>(from call: T, to handler: NetworkErrorFunctionProvider) where T: NetworkCall {
    call.responder?.errorHandler = handler.errorFunction()
}

public func bindErrorData<T>(from call: T, to handler: NetworkErrorFunctionProvider) where T: NetworkCall {
    call.responder?.errorDataHandler = handler.dataFunction()
}
