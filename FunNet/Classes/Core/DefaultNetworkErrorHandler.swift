//
//  DefaultNetworkErrorHandler.swift
//  FunNet
//
//  Created by Calvin Collins on 5/26/21.
//

import UIKit
import LithoUtils
import LithoOperators
import Prelude

public enum ErrorHandlingConfig: UInt8 {
    case none = 0b0
    case print = 0b1
    case debug = 0b10
    case production = 0b100
}

public func defaultErrorHandlingConfig() -> [ErrorHandlingConfig] {
    if (isSimulator()) {
        return [.print, .debug]
    } else {
        return [.print, .production]
    }
}

public struct ErrorHandlingContext {
    var config: UInt8
    public init(_ configs: [ErrorHandlingConfig]) {
        self.config = configs.map(\.rawValue).reduce(0, (|))
    }
}

public protocol NetworkErrorFunctionProvider {
    var errorMessageMap: [Int:String] { get set }
    var serverErrorMessageMap: [Int:String] { get set }
    func errorHandler(_ presenter: UIViewController?) -> (NSError?) -> Void
    func errorDataHandler(_ presenter: UIViewController?) -> (Data?) -> Void
    func serverErrorHandler(_ presenter: UIViewController?) -> (NSError?) -> Void
}

extension NetworkErrorFunctionProvider {
    func errorHandler(_ vc: UIViewController? = nil) -> (NSError?) -> Void {
        return errorHandler(vc)
    }
    
    func errorDataHandler(_ vc: UIViewController? = nil) -> (Data?) -> Void {
        return errorDataHandler(vc)
    }
    
    func serverErrorHandler(_ vc: UIViewController? = nil) -> (NSError?) -> Void {
        return serverErrorHandler(vc)
    }
}

open class NetworkErrHandler<T: Comparable>: NetworkErrorFunctionProvider {
    open var serverErrorMessageMap: [Int : String] = [:]
    open var errorMessageMap: [Int : String] = [:]
    public var config: UInt8
    public var id: T
    public var supercedingHandlers: [NetworkErrHandler<T>]
    
    public init(_ context: ErrorHandlingContext = ErrorHandlingContext(defaultErrorHandlingConfig()), supercedingHandlers: [NetworkErrHandler<T>] = [], id: T, errorMessageMap: [Int:String] = [:], serverErrorMap: [Int:String] = [:]) {
        self.id = id
        self.config = context.config
        self.supercedingHandlers = supercedingHandlers
        self.serverErrorMessageMap = serverErrorMap
        self.errorMessageMap = errorMessageMap
    }
    
    public func serverError(statusCode: Int?, with data: Data?) -> NSError {
        if let data = data, let rubyMessage = try? JSONDecoder().decode(RubyError.self, from: data) {
            return NSError(domain: "Server Error", code: statusCode ?? -1, userInfo: ["message": rubyMessage.message ?? ""])
        }
        return NSError(domain: "Server Error", code: statusCode ?? -1, userInfo: ["message": (data ?> (.utf8 >||> String.init) >>> coalesceNil(with: "")) ?? ""])
    }
    
    public func generalErrorHandler(_ presenter: ((UIViewController) -> Void)?) -> (NSError?, NSError?, (Int?, Data?)) -> Void {
        let errorFromResponse = serverError >>> errorToMessage
        let combiner = tupleMap(optionalize(with: errorToMessage >>> ^\SimpleErrorMessage.description), optionalize(with: errorToMessage >>> ^\SimpleErrorMessage.description), optionalize(with: ~errorFromResponse >>> ^\SimpleErrorMessage.description)) >>> { [$0.0, $0.1, $0.2] }
        return { err, serverErr, response in
            switch reduce(arr: combiner((err, serverErr, response))) {
            case .some(let arr):
                if self.should(.print) {
                    print(arr)
                }
                if self.should(.debug) {
                    let errorString = arr.reduce("", { $0 + "\n\($1)" })
                    presenter?(alertController(title: "Errors", message: errorString))
                }
            case .none:
                break
            }
        }
    }
    
    public func errorHandler(_ vc: UIViewController? = nil) -> (NSError?) -> Void {
        return { err in
            guard let err = err, let handler = self.handler(for: err.code) else { return }
            if handler.should(.print) {
                print(self.errorToMessage(err: err).description)
            }
            if handler.should(.debug) || handler.should(.production) {
                vc?.presentAnimated(handler.alert(for: handler.errorToMessage(err: err)))
            }
        }
    }
    
    public func errorDataHandler(_ vc: UIViewController? = nil) -> (Data?) -> Void {
        return { data in
            guard let data = data else { return }
            let error = self.serverError(statusCode: nil, with: data)
            if self.should(.print) {
                print(self.errorToMessage(err: error).description)
            }
            if self.should(.debug) || self.should(.production) {
                vc?.presentAnimated(self.alert(for: self.errorToMessage(err: error)))
            }
        }
    }
    
    public func serverErrorHandler(_ vc: UIViewController? = nil) -> (NSError?) -> Void {
        return { err in
            guard let err = err, let handler = self.handler(for: err.code) else { return }
            if handler.should(.print) {
                print(self.serverErrorToMessage(err: err).description)
            }
            if self.should(.debug) || self.should(.production) {
                vc?.presentAnimated(self.alert(for: self.serverErrorToMessage(err: err)))
            }
        }
    }
    
    public func handler(for id: T) -> NetworkErrHandler<T> where T: Comparable {
        if let handler = supercedingHandlers.filter(^\.id >>> isEqualTo(id)).first {
            return handler
        } else {
            return self
        }
    }
    
    public func handler(for status: Int) -> NetworkErrHandler<T>? {
        if supercedingHandlers.count == 0 && !(errorMessageMap[status] != nil || serverErrorMessageMap[status] != nil) {
            return nil
        } else {
            if supercedingHandlers.count > 0 {
                return supercedingHandlers.compactMap({ $0.handler(for: status) }).sortedBy(keyPath: \NetworkErrHandler<T>.id).first
            } else {
                return self
            }
        }
    }
    
    public func message(for status: Int) -> String? {
        if let handler = handler(for: status) {
            return status < 400 ? handler.errorMessageMap[status] : handler.serverErrorMessageMap[status]
        } else {
            return status < 400 ? errorMessageMap[status] : serverErrorMessageMap[status]
        }
    }
    
    public func should(_ config: ErrorHandlingConfig) -> Bool {
        return self.config & config.rawValue != 0
    }
    
    open func errorToMessage(err: NSError) -> SimpleErrorMessage {
        if should(.debug) {
            return SimpleErrorMessage(err)
        } else {
            return SimpleErrorMessage(title: "Uh oh!", message: message(for: err.code) ?? "Something went wrong!", forCode: err.code)
        }
    }
    
    open func serverErrorToMessage(err: NSError) -> SimpleErrorMessage {
        if should(.debug) {
            return SimpleErrorMessage(title: "Server Error", message: err.localizedDescription, forCode: err.code)
        } else {
            return SimpleErrorMessage(title: "Uh oh!", message: message(for: err.code) ?? "Something went wrong!", forCode: err.code)
        }
    }
    
    open func alert(for errorMsg: SimpleErrorMessage) -> UIAlertController {
        if (should(.debug)) {
            return alertController(title: "\(errorMsg.title): \(errorMsg.forCode)", message: errorMsg.message)
        } else {
            return alertController(title: "\(errorMsg.title)", message: errorMsg.message)
        }
    }
}

public class DefaultNetworkErrHandler<T: Comparable>: NetworkErrHandler<T> {
    public override init(_ context: ErrorHandlingContext = ErrorHandlingContext(defaultErrorHandlingConfig()), supercedingHandlers: [NetworkErrHandler<T>] = [], id: T, errorMessageMap: [Int : String] = [:], serverErrorMap: [Int : String] = [:]) {
        super.init(context, supercedingHandlers: supercedingHandlers, id: id, errorMessageMap: errorMessageMap, serverErrorMap: serverErrorMap)
        self.errorMessageMap.merge(urlRequestErrorCodesDict, uniquingKeysWith: { first, _ in
            return first
        })
        self.serverErrorMessageMap.merge(urlLoadingErrorCodesDict, uniquingKeysWith: { first, _ in
            return first
        })
    }
    
    public init(_ context: ErrorHandlingContext = ErrorHandlingContext(defaultErrorHandlingConfig()), supercedingHandlers: [NetworkErrHandler<T>] = [], id: T) {
        super.init(context, supercedingHandlers: supercedingHandlers, id: id, errorMessageMap: urlRequestErrorCodesDict, serverErrorMap: urlLoadingErrorCodesDict)
    }
}

public struct RubyError: Codable {
    let message: String?
}

extension SimpleErrorMessage: CustomStringConvertible {
    public var description: String {
        return "\(title): \(forCode), \(message)"
    }
    
    init(_ err: NSError) {
        self.title = err.domain
        self.forCode = err.code
        self.message = (err.userInfo["message"] as? String) ?? "Was unable to decode message."
    }
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

public func optionalize<T, U, V>(with f: @escaping ((T?, U?)) -> V) -> ((T?, U?)?) -> Optional<[V]> {
    return { tuple in
        if tuple != nil {
            return .some([f(tuple!)])
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
