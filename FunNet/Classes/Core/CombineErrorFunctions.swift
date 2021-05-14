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

public func bindErrorPrinting<T: PrintingNetworkErrorHandler>(handler: T) -> (inout NetworkResponder) -> Void {
    return { responder in
        responder.errorHandler = handler.errorFunction() >>> ignoreArg({ })
        responder.serverErrorHandler = handler.errorFunction() >>> ignoreArg({ })
    }
}

public func bindDataPrinting<T: PrintingNetworkErrorHandler>(handler: T) -> (inout NetworkResponder) -> Void {
    return { responder in
        responder.errorDataHandler = handler.dataFunction() >>> ignoreArg({ })
    }
}

public func bindErrorAlert<T: VNetworkErrorHandler>(to vc: UIViewController, handler: T) -> (inout NetworkResponder) -> Void {
    return { responder in
        responder.errorHandler = handler.errorFunction() >?> { [weak vc] presentee in
            vc?.present(presentee, animated: true, completion: nil)
        }
    }
}

public func bindErrorDataAlert<T: VNetworkErrorHandler>(to vc: UIViewController, handler: T) -> (inout NetworkResponder) -> Void {
    return { responder in
        responder.errorDataHandler = handler.dataFunction() >?> { [weak vc] presentee in
            vc?.present(presentee, animated: true, completion: nil)
        }
    }
}

public func debugErrors(displayedIn vc: UIViewController) -> (inout NetworkResponder) -> Void {
    return bindErrorAlert(to: vc, handler: DebugNetworkErrorHandler())
}

public func alertErrors(displayedIn vc: UIViewController) -> (inout NetworkResponder) -> Void {
    return bindErrorAlert(to: vc, handler: AlertNetworkErrorHandler(handledErrors: [:], defaultMessage: nil))
}

public func alertErrors(displayedIn vc: UIViewController, errorMsgs: [Int:String], defaultMessage: String?) -> (inout NetworkResponder) -> Void {
    return bindErrorAlert(to: vc, handler: AlertNetworkErrorHandler(handledErrors: errorMsgs, defaultMessage: defaultMessage))
}

public func verboseErrors(displayedIn vc: UIViewController) -> (ServerCodeNetworkErrorHandler) -> (inout NetworkResponder) -> Void {
    return vc >|> bindErrorAlert
}
//public func bindError(from call: CombineNetCall, to handler: NetworkErrorFunctionProvider, storingIn cancelBag: inout Set<AnyCancellable>) {
//    call.publisher.$error.compactMap(id).sink(receiveValue: handler.errorFunction()).store(in: &cancelBag)
//}
//
//@available(iOS 13.0, *)
//public func bindErrorData(from call: CombineNetCall, to handler: NetworkErrorFunctionProvider, storingIn cancelBag: inout Set<AnyCancellable>) {
//    call.publisher.$errorData.compactMap(id).sink(receiveValue: handler.dataFunction()).store(in: &cancelBag)
//}
//
//public func bindError<T>(from call: T, to handler: NetworkErrorFunctionProvider) where T: NetworkCall {
//    call.responder?.errorHandler = handler.errorFunction()
//}
//
//public func bindErrorData<T>(from call: T, to handler: NetworkErrorFunctionProvider) where T: NetworkCall {
//    call.responder?.errorDataHandler = handler.dataFunction()
//}
