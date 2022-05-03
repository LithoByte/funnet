//
//  CombineNetCallTests.swift
//  FunNet_Tests
//
//  Created by Elliot on 5/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import FunNet

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
        
        XCTAssert(call.isInProgress)
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
