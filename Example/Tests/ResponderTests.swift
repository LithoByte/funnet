//
//  ResponderTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 3/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Prelude
@testable import FunNet

class ResponderTests: XCTestCase {
    func testError() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        let response = HTTPURLResponse(url: URL(string: "https://lithobyte.co/api/v2/apps")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
        
        let completion = responderToCompletion(responder: responder)
        completion(nil, nil, error)
        
        XCTAssert(wasErrorCalled)
        XCTAssert(wasErrorDataCalled)
        XCTAssert(wasResponseCalled)
        XCTAssert(!wasHttpResponseCalled)
        XCTAssert(!wasServerErrorCalled)
        XCTAssert(!wasDataSuccessCalled)
    }
    
    func testErrorData() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        let response = HTTPURLResponse(url: URL(string: "https://lithobyte.co/api/v2/apps")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
        
        let completion = responderToCompletion(responder: responder)
        completion(data, nil, error)
        
        XCTAssert(wasErrorCalled)
        XCTAssert(wasErrorDataCalled)
        XCTAssert(wasResponseCalled)
        XCTAssert(!wasHttpResponseCalled)
        XCTAssert(!wasServerErrorCalled)
        XCTAssert(!wasDataSuccessCalled)
    }
    
    func testResponse() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        let response = URLResponse()//HTTPURLResponse(url: URL(string: "https://lithobyte.co/api/v2/apps")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
        
        let completion = responderToCompletion(responder: responder)
        completion(nil, response, nil)
        
        XCTAssert(!wasErrorCalled)
        XCTAssert(!wasErrorDataCalled)
        XCTAssert(wasResponseCalled)
        XCTAssert(!wasHttpResponseCalled)
        XCTAssert(!wasServerErrorCalled)
        XCTAssert(!wasDataSuccessCalled)
    }
    
    func testHttpResponse() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        let response = HTTPURLResponse(url: URL(string: "https://lithobyte.co/api/v2/apps")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
        
        let completion = responderToCompletion(responder: responder)
        completion(nil, response, nil)
        
        XCTAssert(!wasErrorCalled)
        XCTAssert(!wasErrorDataCalled)
        XCTAssert(wasResponseCalled)
        XCTAssert(wasHttpResponseCalled)
        XCTAssert(!wasServerErrorCalled)
        XCTAssert(wasDataSuccessCalled)
    }
    
    func testStubHttpResponse() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        let call = NetworkCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), endpoint: Endpoint(), responder: responder)
        
        call |> stubHTTPResponse(withStatusCode: 201)
        
        XCTAssert(!wasErrorCalled)
        XCTAssert(!wasErrorDataCalled)
        XCTAssert(!wasResponseCalled)
        XCTAssert(wasHttpResponseCalled)
        XCTAssert(!wasServerErrorCalled)
        XCTAssert(!wasDataSuccessCalled)
    }
    
    func testServerError() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        let response = HTTPURLResponse(url: URL(string: "https://lithobyte.co/api/v2/apps")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let data = Data()
        
        let completion = responderToCompletion(responder: responder)
        completion(nil, response, nil)
        
        XCTAssert(!wasErrorCalled)
        XCTAssert(!wasErrorDataCalled)
        XCTAssert(wasResponseCalled)
        XCTAssert(wasHttpResponseCalled)
        XCTAssert(wasServerErrorCalled)
        XCTAssert(!wasDataSuccessCalled)
    }
    
    func testDataSuccess() {
        var wasErrorCalled = false
        var wasErrorDataCalled = false
        var wasResponseCalled = false
        var wasHttpResponseCalled = false
        var wasServerErrorCalled = false
        var wasDataSuccessCalled = false
        var responder = NetworkResponder()
        responder.errorHandler = { _ in wasErrorCalled = true }
        responder.errorDataHandler = { _ in wasErrorDataCalled = true }
        responder.responseHandler = { _ in wasResponseCalled = true }
        responder.httpResponseHandler = { _ in wasHttpResponseCalled = true }
        responder.serverErrorHandler = { _ in wasServerErrorCalled = true }
        responder.dataHandler = { _ in wasDataSuccessCalled = true }
        
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        let response = HTTPURLResponse(url: URL(string: "https://lithobyte.co/api/v2/apps")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
        
        let completion = responderToCompletion(responder: responder)
        completion(data, response, nil)
        
        XCTAssert(!wasErrorCalled)
        XCTAssert(!wasErrorDataCalled)
        XCTAssert(wasResponseCalled)
        XCTAssert(wasHttpResponseCalled)
        XCTAssert(!wasServerErrorCalled)
        XCTAssert(wasDataSuccessCalled)
    }
}
