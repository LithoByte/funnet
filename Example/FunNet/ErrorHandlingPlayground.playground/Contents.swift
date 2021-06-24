import UIKit
import FunNet
import Combine
import Slippers
import LithoOperators
import fuikit
import PlaygroundSupport
import PlaygroundVCHelpers
import Prelude

var cancelBag: Set<AnyCancellable> = []
let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "api/v1"), Endpoint())
class RubyError: FunNetErrorData {
    public var message: String?
    
    public init(_ message: String?) {
        self.message = message
    }
}

let rubyError = RubyError("User is unauthorized.")
let rubyErrorData = JsonProvider.encode(rubyError)!

let handledHTTPResponse = HTTPURLResponse(url: URL(string: call.configuration.toBaseUrlString())!, statusCode: 401, httpVersion: nil, headerFields: nil)!
let serverError = NSError(domain: "Error", code: 401, userInfo: nil)
let error = NSError(domain: "Error", code: -1000, userInfo: nil)

call.firingFunc = { call in
    call.publisher.error = error
    call.publisher.serverError = serverError
    call.publisher.httpResponse = handledHTTPResponse
    call.publisher.errorData = rubyErrorData
}

call.publisher.$httpResponse.sink(receiveValue: printingHttpResponseErrorHandler(errorMap: [401: "User is not authorized, errorMap used"])).store(in: &cancelBag)
call.publisher.$error.sink(receiveValue: printingServerErrorHandler(errorMap: [-1000: "Bad Url, errorMap used"])).store(in: &cancelBag)
call.publisher.$serverError.sink(receiveValue: printingServerErrorHandler(errorMap: [401: "User is not authorized, errorMap used"]))
call.publisher.$errorData.sink(receiveValue: printingErrorDataHandler(type: RubyError.self)).store(in: &cancelBag)
call.publisher.$httpResponse.combineLatest(call.publisher.$errorData).sink(receiveValue: ~(printingFunNetErrorDataHandler(type: RubyError.self))).store(in: &cancelBag)

//call.fire()

// --------------------------------------------------------------------

public func dataTaskCompletionError(completion: Subscribers.Completion<URLError>) -> URLError? {
    switch completion {
    case .finished:
        return nil
    case .failure(let error):
        return error
    }
}

// This is how users of URLSession might set up their request
let request = URLRequest(url: URL(string: "https://lithobyte.co/api/v1")!)
let session = URLSession(configuration: .default)
var taskPub = session.dataTaskPublisher(for: request).eraseToAnyPublisher()

// Stubbing so we don't have to fire the request
let taskSubject = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
taskPub = taskSubject.eraseToAnyPublisher()

// Subscribing to the publisher, looking for errors

let errorCodeString: (Int) -> String? = { "Error \($0):" }
let printTwoStrs: (String?, String?) -> Void = { print($0! as Any, $1! as Any) }

let printCompletion: (Subscribers.Completion<URLError>) -> Void = dataTaskCompletionError >?> ^\URLError.errorCode >>> fzip(errorCodeString, keyToValue(for: urlLoadingErrorCodesDict)) >>> printTwoStrs
let printValue: ((Int?, RubyError?)) -> Void = statusAndFunNetErrorDataToString >>> printStr
taskPub
    .map(flip(responseToFunNetErrorData(type: RubyError.self)))
    .sink(receiveCompletion: printCompletion, receiveValue: printValue)
    .store(in: &cancelBag)

taskPub.sink(receiveCompletion: dataTaskCompletionError >?> ^\URLError.errorCode >>> fzip(errorCodeString, keyToValue(for: urlLoadingErrorCodesDict)) >>> printTwoStrs, receiveValue: responderToTaskPublisherReceiver(responder: call.publisher))
    .store(in: &cancelBag)

// Send a response to test printing
taskSubject.send((rubyErrorData, handledHTTPResponse))
taskSubject.send(completion: Subscribers.Completion<URLError>.failure(URLError.init(.badURL, userInfo: [:])))
//taskSubject.send(completion: Subscribers.Completion<URLError>.finished)
