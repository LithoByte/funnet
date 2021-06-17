//: A UIKit based Playground for presenting user interface
  
import UIKit
import FunNet
import Combine
import Slippers
import LithoOperators

var cancelBag: Set<AnyCancellable> = []
let call = CombineNetCall(configuration: ServerConfiguration(host: "https://lithobyte.co", apiRoute: "api/v1"), Endpoint())

class RubyError: FunNetworkError {
    public var message: String?
    
    public init(_ message: String?) {
        self.message = message
    }
}

let rubyError = RubyError("User is unauthorized.")
let rubyErrorData = JsonProvider.encode(rubyError)!

let handledHTTPResponse = HTTPURLResponse(url: URL(string: call.configuration.toBaseUrlString())!, statusCode: 401, httpVersion: nil, headerFields: nil)
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
call.publisher.$httpResponse.combineLatest(call.publisher.$errorData).sink(receiveValue: ~(printingFunNetworkErrorHandler(type: RubyError.self))).store(in: &cancelBag)

call.fire()
