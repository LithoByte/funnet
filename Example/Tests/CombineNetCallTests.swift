//
//  CombineNetCallTests.swift
//  FunNet_Tests
//
//  Created by Elliot on 5/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import FunNet
import LithoOperators
import Combine

class CombineNetCallTests: XCTestCase {
    func testIsInProgressInit() throws {
        let call = CombineNetCall(configuration: ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default), Endpoint())
        
        XCTAssertFalse(call.isInProgress)
    }
    
    func testIsInProgressFired() throws {
        let call = CombineNetCall(configuration: ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default), Endpoint())
        call.firingFunc = { _ in }
        
        call.fire()
        
        XCTAssert(call.isInProgress)
    }
    
    func testIsInProgressReturned() throws {
        let call = CombineNetCall(configuration: ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default), Endpoint())
        call.firingFunc = { $0.responder.dataHandler(Data()) }
        
        call.fire()
        
        XCTAssertFalse(call.isInProgress)
    }
    
    func testIsInProgressMinimalPublishing() throws {
        var cancelBag = Set<AnyCancellable>()
        var wasCalled = false
        var wasCalledTwice = false
        var wasCalledThrice = false
        var sentData = false
        var sentError = false
        let setCalled = {
            if !wasCalled {
                wasCalled = true
            } else if !wasCalledTwice {
                wasCalledTwice = true
            } else {
                wasCalledThrice = true
            }
        }
        let call = CombineNetCall(configuration: ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default), Endpoint())
        let sendData: (NetworkCall) -> Void = {
            $0.responder.dataHandler(Data())
            sentData = true
        }
        let sendError: (NetworkCall) -> Void = {
            $0.responder.errorHandler(NSError())
            sentError = true
        }
        call.firingFunc = sendData <> sendError
        call.$isInProgress.dropFirst().sink(receiveValue: ignoreArg(setCalled)).store(in: &cancelBag)
        
        call.fire()
        
        XCTAssert(sentData)
        XCTAssert(sentError)
        XCTAssertFalse(call.isInProgress)
        XCTAssert(wasCalled)
        XCTAssert(wasCalledTwice)
        XCTAssertFalse(wasCalledThrice)
    }
    
    func testFireInit() throws {
        let call = CombineNetCall(configuration: ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default), Endpoint())
        var wasCalled = false
        
        call.firingFunc = { _ in wasCalled = true }
        
        XCTAssertFalse(wasCalled)
    }
    
    func testFire() throws {
        let call = CombineNetCall(configuration: ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default), Endpoint())
        var wasCalled = false
        call.firingFunc = { _ in wasCalled = true }
        
        call.fire()
        
        XCTAssert(wasCalled)
    }
}
