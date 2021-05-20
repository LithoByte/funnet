//
//  NetworkErrorHandler.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/12/19.
//

import UIKit
import LithoOperators
import Prelude

public protocol ErrorMessage {
    var title: String { get }
    var message: String { get }
    var forCode: Int { get }
}

public struct SimpleErrorMessage: ErrorMessage {
    public var title: String
    public var message: String
    public var forCode: Int
}

public protocol NetworkErrorHandler {
    func alert(for error: NSError) -> UIViewController
}

public class VerboseLoginErrorHandler: VerboseNetworkErrorHandler {
    public override init() {
        super.init()
        errorMessages.append(DefaultEmailPasswordLoginErrorMessage())
    }
}

public class VerboseNetworkErrorHandler: NetworkErrorHandler {
    var errorMessages: [ErrorMessage] = [DefaultServerUnavailableErrorMessage(), DefaultServerIssueErrorMessage(), DefaultOfflineErrorMessage()]
    var errorMessageMap: [Int: ErrorMessage] {
        get {
            var map = [Int: ErrorMessage]()
            for message in errorMessages {
                map[message.forCode] = message
            }
            return map
        }
    }
    
    public init() {}
    
    open func alert(for error: NSError) -> UIViewController {
        print(error)
        if let message = errorMessageMap[error.code] {
            return FunNet.alert(message.title, message.message)
        } else {
            return FunNet.alert("Error \(error.code)", "Description: \(error.debugDescription)\nInfo: \(error.userInfo)")
        }
    }
    
    open func notify(title: String, message: String) {
        FunNet.alert(title, message).show(animated: true)
    }
}

public func alert(_ title: String, _ message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
    }))
    return alert
}

public struct DefaultServerUnavailableErrorMessage: ErrorMessage {
    public let title: String = "Error"
    public let message: String = "The server is unavailable! Try again in a bit. If this keeps happening, please let us know!"
    public let forCode: Int = 503
    
    public init() {}
}

public struct DefaultServerIssueErrorMessage: ErrorMessage {
    public let title: String = "Error"
    public let message: String = "Looks like we're having a problem. Please contact us to let us know."
    public let forCode: Int = 500
    
    public init() {}
}

public struct DefaultOfflineErrorMessage: ErrorMessage {
    public let title: String = "Hmmm..."
    public let message: String = "Looks like you're offline. Try reconnecting to the internet."
    public let forCode: Int = -1009
    
    public init() {}
}

public struct DefaultUsernamePasswordLoginErrorMessage: ErrorMessage {
    public let title: String = "Oops!"
    public let message: String = "Looks like your username or password is incorrect."
    public let forCode: Int = 401
    
    public init() {}
}

public struct DefaultEmailPasswordLoginErrorMessage: ErrorMessage {
    public let title: String = "Oops!"
    public let message: String = "Looks like your email or password is incorrect. Try again!"
    public let forCode: Int = 401
    
    public init() {}
}

extension UIAlertController {
    public func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindow.Level.alert
        
        if let rootViewController = window.rootViewController {
            window.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
    }
}

private let none: UInt8 = 0b0
private let printingFlag: UInt8 = 0b1
private let debugAlertFlag: UInt8 = 0b10
private let printingAlertFlag: UInt8 = 0b100

public enum ErrorHandlingConfig: UInt8 {
    case none = 0b0
    case print = 0b1
    case debug = 0b10
    case production = 0b100
}

public protocol NetworkErrorFunctionProvider {
    var errorMessageMap: [Int:String] { get set }
    func errorHandler(_ error: NSError?) -> Void
    func errorDataHandler(_ errorData: Data?) -> Void
    func serverErrorHandler(_ serverError: NSError?) -> Void
}

//SHOULD GO INTO LITHOOPERATORS, AND BE RENAMED (?)
public func fzip<T, U, V, W, X, Y>(_ f: @escaping (T) -> W, _ g: @escaping (U) -> X, _ h: @escaping (V) -> Y) -> (T, U, V) -> (W, X, Y) {
    return { t, u, v in
        (f(t), g(u), h(v))
    }
}

public class NetworkErrHandler: NetworkErrorFunctionProvider {
    public var errorMessageMap: [Int : String] = urlRequestErrorCodesDict
    public var serverErrorMessageMap = urlLoadingErrorCodesDict
    public var config: UInt8
    public let errorDataToString: (Data) -> String = .utf8 >||> String.init(data:encoding:) >>> coalesceNil(with: "Could not decode data.")
    public let presenter: (UIViewController) -> Void
    
    public init(configs: ErrorHandlingConfig..., errorMessageMap: [Int:String] = [:], serverErrorMessageMap: [Int:String] = [:], presenter: @escaping (UIViewController) -> Void) {
        self.config = configs.map(\.rawValue).reduce(0, { $0 | $1 })
        self.presenter = presenter
        for (code, message) in errorMessageMap {
            self.errorMessageMap[code] = message
        }
        for (code, message) in serverErrorMessageMap {
            self.serverErrorMessageMap[code] = message
        }
    }
    
    public func generalErrorHandler(_ error: NSError?, serverError: NSError?, errorData: Data?) {
        let combiner = fzip(optionalize(with: errorToString), optionalize(with: serverErrorToString), optionalize(with: errorDataToString)) >>> { [$0.0, $0.1, $0.2] }
        switch reduce(arr: combiner((error, serverError, errorData))) {
        case .some(let arr):
            if should(.print) {
                print(arr)
            }
            if should(.debug) || should(.production) {
                let errorString = arr.reduce("", { $0 + "\n\($1)"})
                errorString |> (("Errors" >|> alert) >>> presenter)
            }
        case .none:
            break
        }
    }
    
    public func errorHandler(_ error: NSError?) {
        if should(.print) {
            error ?> errorToString >>> { print($0) }
        }
        if should(.debug) || should(.production) {
            error ?> (errorToString >>> ("Error \(errorCode(for: error))" >|> alert) >>> presenter)
        }
    }
    
    public func errorDataHandler(_ errorData: Data?) {
        if should(.print) {
            errorData ?> errorDataToString >>> { print($0) }
        }
        if should(.debug) || should(.production) {
            errorData ?> (errorDataToString >>> ("Error" >|> alert(_:_:)) >>> presenter)
        }
    }
    
    public func serverErrorHandler(_ serverError: NSError?) {
        if should(.print) {
            serverError ?> serverErrorToString >>> { print($0) }
        }
        if should(.debug) || should(.production) {
            serverError ?> (serverErrorToString >>> ("Server Error \(errorCode(for: serverError))" >|> alert) >>> presenter)
        }
    }
    
    public func errorToString(_ error: NSError) -> String {
        return should(.debug) ? "Response Error:\n Domain: \(error.domain), Description: \(error.localizedDescription), Code: \(error.code)" : errorMessageMap[error.code] ?? "Response Error: Status code was not handled"
    }
    
    public func serverErrorToString(_ serverError: NSError) -> String {
        return should(.debug) ?  "Server Error:\n Domain: \(serverError.domain), Description: \(serverError.localizedDescription), Code: \(serverError.code)" : serverErrorMessageMap[serverError.code] ?? "Server Error: Status code was not handled."
    }
    
    public func should(_ op: ErrorHandlingConfig) -> Bool {
        return (op.rawValue & config) != 0
    }
}

public func errorCode(for error: NSError?) -> String {
    guard let err = error else { return ""}
    return "\(err.code)"
}

public func optionalize<T, U>(with f: @escaping (T) -> U) -> (T?) -> Optional<[U]> {
    return { t in
        if t != nil {
            return .some([f(t!)])
        } else {
            return .none
        }
    }
}

public func combine<T>(a: Optional<[T]>, b: Optional<[T]>) -> Optional<[T]> {
    switch (a, b) {
    case (.some(let arr1), .some(let arr2)):
        return .some(arr1 + arr2)
    case (.some, .none):
        return a
    case (.none, .some):
        return b
    case (.none, .none):
        return .none
    }
}

public func reduce<T>(arr: [Optional<[T]>]) -> Optional<[T]> {
    return arr.reduce(.none, combine)
}

//public enum ErrorHandlingConfig {
//    case print, debug, alert, printAndAlert
//}
//
//public protocol NetworkErrorFunctionProvider {
//    func errorFunction() -> (NSError?) -> UIViewController?
//    func dataFunction() -> (Data?) -> UIViewController?
//}
//
//public class PrintingNetworkErrorHandler: NetworkErrorFunctionProvider {
//    public func dataFunction() -> (Data?) -> UIViewController? {
//        return { data in
//            print("Payload: \(String(data: data ?? Data([]), encoding: .utf8) ?? "None")")
//            return nil
//        }
//    }
//
//    public func errorFunction() -> (NSError?) -> UIViewController? {
//        return { err in
//            print("Server Error: \(err?.domain ?? "No title")")
//            print("URL: \(err?.userInfo["url"] ?? "none")")
//            print("Status Code: \(err?.code ?? -1)")
//            return nil
//        }
//    }
//}
//
//public protocol VNetworkErrorHandler: NetworkErrorFunctionProvider {
//    var errorMessageMap: [Int:String] { get set }
//
//    func alert(for error: NSError?) -> UIAlertController
//    func alert(_ title: String, _ message: String) -> UIAlertController
//}
//
//extension VNetworkErrorHandler {
//    public func alert(for error: NSError?) -> UIAlertController {
//        if let message = errorMessageMap[error?.code ?? -1] {
//            return alert("\(error?.code ?? -1)", message)
//        } else {
//            return alert("Error \(error?.code ?? -1)", "Description: \(error?.debugDescription ?? "None")\nInfo: \(String(describing: error?.userInfo))")
//        }
//    }
//
//    public func alert(_ title: String, _ message: String) -> UIAlertController {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }))
//        return alert
//    }
//}
//
//public class DebugNetworkErrorHandler: VNetworkErrorHandler {
//
//
//    open var errorMessageMap: [Int:String] = [
//        400 : "Bad request",
//        401 : "Unauthorized",
//        402 : "Payment required",
//        403 : "Forbidden",
//        404 : "Not found",
//        405 : "HTTP Method not allowed",
//        406 : "Content type in Accept header is unavailable",
//        408 : "Request timed out",
//        409 : "Conflict in requested resource",
//        410 : "Resource is permanently unavailable",
//        411 : "Length required",
//        412 : "Precondition failed",
//        413 : "Payload too large",
//        414 : "URI too long",
//        415 : "Unsupported mediatype",
//        416 : "Range not satisfiable",
//        417 : "Expectation failed",
//        418 : "This server is, in fact, a teapot",
//        420 : "420 error, dank dude",
//        421 : "Unauthorized",
//        422 : "Unable to process payload",
//        429 : "Too many requests",
//        431 : "Headers too large",
//        451 : "Unavailable for legal reasons",
//        500 : "Internal server error",
//        501 : "This functionality is not implemented",
//        502 : "Bad internet gateway",
//        503 : "Server currently unavailable",
//        505 : "HTTP version not supported",
//        511 : "Network authentication required"
//    ].merging(urlLoadingErrorCodesDict, uniquingKeysWith: { _, key in return key })
//
//    public func errorFunction() -> (NSError?) -> UIViewController? {
//        return { err in
//            return self.alert(for: err)
//        }
//    }
//
//    public func dataFunction() -> (Data?) -> UIViewController? {
//        return { data in
//            let payload = String(data: data ?? Data([]), encoding: .utf8)
//            return self.alert("Error", payload ?? "")
//        }
//    }
//}
//
//public class AlertNetworkErrorHandler: VNetworkErrorHandler {
//
//    open var errorMessageMap: [Int:String] = urlLoadingErrorCodesDict
//    var defaultMessage: String?
//
//    public init(handledErrors: [Int:String], defaultMessage: String?) {
//        for (code, message) in handledErrors {
//            errorMessageMap[code] = message
//        }
//        self.defaultMessage = defaultMessage
//    }
//
//    public func errorFunction() -> (NSError?) -> UIViewController? {
//        return { err in
//            return self.alert(for: err)
//        }
//    }
//
//    public func dataFunction() -> (Data?) -> UIViewController? {
//        return { data in
//            let payload = String(data: data ?? Data([]), encoding: .utf8)
//            return self.alert("Error", payload ?? "")
//        }
//    }
//
//    public func alert(for error: NSError?) -> UIAlertController {
//        if let message = errorMessageMap[error?.code ?? -1] {
//            return alert("Oops!", message)
//        } else {
//            return alert("Oops!", defaultMessage ?? "")
//        }
//    }
//}
//
//public class ServerCodeNetworkErrorHandler: VNetworkErrorHandler {
//
//    public var errorMessageMap: [Int : String]
//    public var defaultMessage: String?
//    public var dataConfig: ErrorHandlingConfig
//    public var errorConfig: ErrorHandlingConfig
//
//    public init(errorMap: [Int:String], defaultMessage: String?, dataConfig: ErrorHandlingConfig, errorConfig: ErrorHandlingConfig) {
//        self.errorMessageMap = errorMap
//        self.defaultMessage = defaultMessage
//        self.dataConfig = dataConfig
//        self.errorConfig = errorConfig
//    }
//
//    public func errorFunction() -> (NSError?) -> UIViewController? {
//        switch errorConfig {
//        case .print:
//            return PrintingNetworkErrorHandler().errorFunction()
//        case .debug:
//            return DebugNetworkErrorHandler().errorFunction()
//        case .alert:
//            return AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).errorFunction()
//        case .printAndAlert:
//            return fzip(AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).errorFunction(), PrintingNetworkErrorHandler().errorFunction()) >>> first
//        }
//    }
//
//    public func dataFunction() -> (Data?) -> UIViewController? {
//        switch dataConfig {
//        case .print:
//            return PrintingNetworkErrorHandler().dataFunction()
//        case .debug:
//            return DebugNetworkErrorHandler().dataFunction()
//        case .alert:
//            return AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).dataFunction()
//        case .printAndAlert:
//            return fzip(AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).dataFunction(), PrintingNetworkErrorHandler().dataFunction()) >>> first
//        }
//    }
//}
