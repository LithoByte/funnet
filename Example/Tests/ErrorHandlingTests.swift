//
//  ErrorHandlingTests.swift
//  FunNet_Tests
//
//  Created by Calvin Collins on 6/23/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import LithoUtils
import Slippers
import Combine
import LithoOperators
@testable import FunNet

class ErrorHandlingTests: XCTestCase {
    var cancelBag: Set<AnyCancellable> = []
    var call: CombineNetCall!
    
    override func setUp() {
        let call = CombineNetCall(configuration: ServerConfiguration(host: "http", apiRoute: ""), Endpoint())
        let handledHTTPResponse = HTTPURLResponse(url: URL(string: call.configuration.toBaseUrlString())!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        call.firingFunc = { call in
            call.publisher.error = error
            call.publisher.serverError = serverError
            call.publisher.httpResponse = handledHTTPResponse
            call.publisher.errorData = rubyErrorData
        }
        self.call = call
    }
    
    func testDebugLoadingErrorHandler() {
        call.publisher.$error.sink(receiveValue: debugLoadingErrorHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Error: -1000")
            XCTAssertEqual(alert.message, "")
        })).store(in: &cancelBag)
        call.fire()
    }
    
    func testDebugServerErrorHandler() {
        call.publisher.$serverError.sink(receiveValue: debugServerErrorHandler(presenter: { (vc: UIViewController?) in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Error: 401")
            XCTAssertEqual(alert.message, "")
        })).store(in: &cancelBag)
        call.fire()
    }
    
    func testDebugHTTPResponseHandler() {
        call.publisher.$httpResponse.sink(receiveValue: debugURLResponseHandler(presenter: { (vc: UIViewController?) in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Error: 401")
            XCTAssertEqual(alert.message, "")
        })).store(in: &cancelBag)
        call.fire()
    }
    
    func testDebugFunNetErrorDataHandler() {
        call.publisher.$httpResponse.combineLatest(call.publisher.$errorData).sink(receiveValue: ~(debugFunNetErrorDataResponseHandler(presenter: { (vc: UIViewController?) in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Error 401")
            XCTAssertEqual(alert.message, rubyError.message)
        }, type: RubyError.self))).store(in: &cancelBag)
        call.fire()
    }
    
    func testProdLoadingErrorHandler() {
        call.publisher.$error.sink(receiveValue: prodLoadingErrorHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Something went wrong!")
            XCTAssertEqual(alert.message, "Testing")
        }, errorMap: [-1000:"Testing"])).store(in: &cancelBag)
        call.fire()
    }
    
    func testProdServerErrorHandler() {
        call.publisher.$serverError.sink(receiveValue: prodServerErrorHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Something went wrong!")
            XCTAssertEqual(alert.message, "Testing")
        }, errorMap: [401:"Testing"])).store(in: &cancelBag)
        call.fire()
    }
    
    func testProdResponseHandler() {
        call.publisher.$httpResponse.sink(receiveValue: prodURLResponseHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Something went wrong!")
            XCTAssertEqual(alert.message, "Testing")
        }, errorMap: [401:"Testing"])).store(in: &cancelBag)
        call.fire()
    }
    
    func testProdFunNetErrorDataHandler() {
        call.publisher.$errorData.sink(receiveValue: prodFunNetErrorDataResponseHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Something went wrong!")
            XCTAssertEqual(alert.message, rubyError.message)
        }, type: RubyError.self)).store(in: &cancelBag)
        call.fire()
    }
    
    func testProdLoadingErrorHandlerDefault() {
        call.publisher.$error.sink(receiveValue: prodLoadingErrorHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Something went wrong!")
            XCTAssertEqual(alert.message, urlLoadingErrorCodesDict[-1000])
        })).store(in: &cancelBag)
        call.fire()
    }
    
    func testProdResponseErrorHandlerDefault() {
        call.publisher.$httpResponse.sink(receiveValue: prodURLResponseHandler(presenter: { vc in
            guard let alert = vc as? UIAlertController else { return XCTFail("Was not UIAlertController") }
            XCTAssertEqual(alert.title, "Something went wrong!")
            XCTAssertEqual(alert.message, urlResponseErrorMessages[401])
        })).store(in: &cancelBag)
        call.fire()
    }
}

class RubyError: FunNetErrorData {
    public var message: String?
    
    public init(_ message: String?) {
        self.message = message
    }
}

let rubyError = RubyError("User is unauthorized.")
let rubyErrorData = JsonProvider.encode(rubyError)!


let serverError = NSError(domain: "Error", code: 401, userInfo: nil)
let error = NSError(domain: "Error", code: -1000, userInfo: nil)
