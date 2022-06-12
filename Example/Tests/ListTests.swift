//
//  ListTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 6/12/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import FunNet
import Combine
import LithoOperators
import Prelude

class ListTests: XCTestCase {
    func testNextPage() throws {
        var wasCalled = false
        var countKey = "per"
        var perPage = 20
        var pageKey = "page"
        var firstPage = 1
        let call = CombineNetCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), Endpoint())
        call.firingFunc = { _ in wasCalled = true }
        
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        
        XCTAssert(wasCalled)
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey)).count, 1)
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(countKey)).first?.value, "\(perPage)")
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(countKey)).count, 1)
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey)).first?.value, "\(firstPage)")
        
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey)).first?.value, "\(firstPage + 1)")
        
        pageKey = "page-number"
        countKey = "count"
        perPage = 25
        firstPage = 0
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey)).count, 1)
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(countKey)).first?.value, "\(perPage)")
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(countKey)).count, 1)
        XCTAssertEqual(call.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey)).first?.value, "\(firstPage)")
    }
    
    func testDefaultShouldLoadNextPage() throws {
        XCTAssert(defaultShouldLoadNextPage(30, 5, 30, 25))
        XCTAssert(defaultShouldLoadNextPage(30, 5, 60, 55))
        XCTAssertFalse(defaultShouldLoadNextPage(30, 5, 30, 0))
        XCTAssertFalse(defaultShouldLoadNextPage(30, 5, 30, 1))
        XCTAssertFalse(defaultShouldLoadNextPage(30, 5, 30, 24))
        XCTAssertFalse(defaultShouldLoadNextPage(30, 5, 60, 54))
    }
}
