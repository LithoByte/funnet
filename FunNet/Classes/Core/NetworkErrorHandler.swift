//
//  NetworkErrorHandler.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/12/19.
//

import UIKit
import LithoOperators

public protocol ErrorMessage {
    var title: String { get }
    var message: String { get }
    var forCode: Int { get }
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
            return alert(message.title, message.message)
        } else {
            return alert("Error \(error.code)", "Description: \(error.debugDescription)\nInfo: \(error.userInfo)")
        }
    }
    
    open func notify(title: String, message: String) {
        alert(title, message).show(animated: true)
    }
    
    func alert(_ title: String, _ message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }
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

public struct NetworkErrorMessage: ErrorMessage {
    public let response: HTTPURLResponse?
    public let title: String
    public let message: String
    public let forCode: Int
    
    public init(title: String, message: String, forCode: Int, response: HTTPURLResponse?) {
        self.title = title
        self.message = message
        self.forCode = forCode
        self.response = response
    }
}

public enum ErrorHandlingConfig {
    case print, debug, alert, printAndAlert
}

protocol NetworkErrorFunctionProvider {
    func errorFunction() -> (NSError?) -> Void
    func dataFunction() -> (Data?) -> Void
}

public class PrintingNetworkErrorHandler: NetworkErrorFunctionProvider {
    func dataFunction() -> (Data?) -> Void {
        return { data in
            print("Payload: \(String(data: data ?? Data([]), encoding: .utf8) ?? "None")")
        }
    }
    
    func errorFunction() -> (NSError?) -> Void {
        return { err in
            print("Server Error: \(err?.domain ?? "No title")")
            print("URL: \(err?.userInfo["url"] ?? "none")")
            print("Status Code: \(err?.code ?? -1)")
        }
    }
}

protocol VNetworkErrorHandler: NetworkErrorFunctionProvider {
    var errorMessageMap: [Int:String] { get set }
    
    func alert(for error: NSError?) -> UIAlertController
    func alert(_ title: String, _ message: String) -> UIAlertController
}

extension VNetworkErrorHandler {
    func alert(for error: NSError?) -> UIAlertController {
        if let message = errorMessageMap[error?.code ?? -1] {
            return alert("\(error?.code ?? -1)", message)
        } else {
            return alert("Error \(error?.code ?? -1)", "Description: \(error?.debugDescription ?? "None")\nInfo: \(String(describing: error?.userInfo))")
        }
    }
    
    func alert(_ title: String, _ message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }
}

public class DebugNetworkErrorHandler: VNetworkErrorHandler {
    
    
    open var errorMessageMap: [Int:String] = [
        400 : "Bad request",
        401 : "Unauthorized",
        402 : "Payment required",
        403 : "Forbidden",
        404 : "Not found",
        405 : "HTTP Method not allowed",
        406 : "Content type in Accept header is unavailable",
        408 : "Request timed out",
        409 : "Conflict in requested resource",
        410 : "Resource is permanently unavailable",
        411 : "Length required",
        412 : "Precondition failed",
        413 : "Payload too large",
        414 : "URI too long",
        415 : "Unsupported mediatype",
        416 : "Range not satisfiable",
        417 : "Expectation failed",
        418 : "This server is, in fact, a teapot",
        420 : "420 error, dank dude",
        421 : "Unauthorized",
        422 : "Unable to process payload",
        429 : "Too many requests",
        431 : "Headers too large",
        451 : "Unavailable for legal reasons",
        500 : "Internal server error",
        501 : "This functionality is not implemented",
        502 : "Bad internet gateway",
        503 : "Server currently unavailable",
        505 : "HTTP version not supported",
        511 : "Network authentication required"
    ]
    
    func errorFunction() -> (NSError?) -> Void {
        return { err in
            self.alert(for: err).show()
        }
    }
    
    func dataFunction() -> (Data?) -> Void {
        return { data in
            let payload = String(data: data ?? Data([]), encoding: .utf8)
            self.alert("Error", payload ?? "").show()
        }
    }
}

public class AlertNetworkErrorHandler: VNetworkErrorHandler {
    
    open var errorMessageMap: [Int:String] = [:]
    var defaultMessage: String?
    
    public init(handledErrors: [Int:String], defaultMessage: String?) {
        for (code, message) in handledErrors {
            errorMessageMap[code] = message
        }
        self.defaultMessage = defaultMessage
    }
    
    func errorFunction() -> (NSError?) -> Void {
        return { err in
            self.alert(for: err).show()
        }
    }
    
    func dataFunction() -> (Data?) -> Void {
        return { data in
            let payload = String(data: data ?? Data([]), encoding: .utf8)
            self.alert("Error", payload ?? "").show()
        }
    }
    
    func alert(for error: NSError?) -> UIAlertController {
        if let message = errorMessageMap[error?.code ?? -1] {
            return alert("Oops!", message)
        } else {
            return alert("Oops!", defaultMessage ?? "")
        }
    }
}

public class ServerCodeNetworkErrorHandler: VNetworkErrorHandler {
    
    public var errorMessageMap: [Int : String]
    public var defaultMessage: String?
    public var dataConfig: ErrorHandlingConfig
    public var errorConfig: ErrorHandlingConfig
    
    public init(errorMap: [Int:String], defaultMessage: String?, dataConfig: ErrorHandlingConfig, errorConfig: ErrorHandlingConfig) {
        self.errorMessageMap = errorMap
        self.defaultMessage = defaultMessage
        self.dataConfig = dataConfig
        self.errorConfig = errorConfig
    }
    
    func errorFunction() -> (NSError?) -> Void {
        switch errorConfig {
        case .print:
            return PrintingNetworkErrorHandler().errorFunction()
        case .debug:
            return DebugNetworkErrorHandler().errorFunction()
        case .alert:
            return AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).errorFunction()
        case .printAndAlert:
            return AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).errorFunction() <> PrintingNetworkErrorHandler().errorFunction()
        }
    }
    
    func dataFunction() -> (Data?) -> Void {
        switch dataConfig {
        case .print:
            return PrintingNetworkErrorHandler().dataFunction()
        case .debug:
            return DebugNetworkErrorHandler().dataFunction()
        case .alert:
            return AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).dataFunction()
        case .printAndAlert:
            return AlertNetworkErrorHandler(handledErrors: errorMessageMap, defaultMessage: defaultMessage).dataFunction() <> PrintingNetworkErrorHandler().dataFunction()
        }
    }
}
