//
//  NetworkErrorHandlerTests.swift
//  FunNet_Tests
//
//  Created by Calvin Collins on 5/27/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import FunNet

class NetworkErrorHandlerTests: XCTestCase {
    func testHandlerForStatusCode() {
        let loginHandler = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [], id: 2, errorMessageMap: [401: "Username or password incorrect."])
        let adminHandler = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [], id: 1, errorMessageMap: [401: "User is not admin"])
        let generalHandler = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [loginHandler], id: 0, errorMessageMap: [401: "User unauthorized", 404: "Not found"])
        let generalHandler2 = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [loginHandler, adminHandler], id: 3, errorMessageMap: [401: "User unauthorized"])
        //Error Handled, no children
        XCTAssertNotNil(loginHandler.handler(for: 401))
        XCTAssertEqual(loginHandler.handler(for: 401)!.id, loginHandler.id)
        //Error Handled, with supercedence
        XCTAssertNotNil(generalHandler.handler(for: 401))
        XCTAssertEqual(generalHandler.handler(for: 401)!.id, loginHandler.id)
        //Error Handled, with supercedence, and handling conflict
        XCTAssertNotNil(generalHandler2.handler(for: 401))
        XCTAssertEqual(generalHandler2.handler(for: 401)!.id, adminHandler.id)
        //Error not handled
        XCTAssertNil(adminHandler.handler(for: 402))
    }
    
    func testMessages() {
        let loginHandler = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [], id: 2, errorMessageMap: [401: "Username or password incorrect."])
        let adminHandler = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [], id: 1, errorMessageMap: [401: "User is not admin"])
        let generalHandler = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [loginHandler], id: 0, errorMessageMap: [401: "User unauthorized", 404: "Not found"])
        let generalHandler2 = NetworkErrHandler<Int>(ErrorHandlingContext([.print]), supercedingHandlers: [loginHandler, adminHandler], id: 3, errorMessageMap: [401: "User unauthorized"])
        
        XCTAssertNotNil(loginHandler.message(for: 401))
        XCTAssertEqual(loginHandler.message(for: 401)!, "Username or password incorrect.")
        
        XCTAssertNotNil(generalHandler.message(for: 401))
        XCTAssertEqual(generalHandler.message(for: 401)!, "Username or password incorrect.")
        
        XCTAssertNotNil(generalHandler2.message(for: 401))
        XCTAssertEqual(generalHandler2.message(for: 401)!, "User is not admin")
    }
}
