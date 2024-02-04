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
    var cancelBag = Set<AnyCancellable>()
    
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
    
    func testPagePipeline() throws {
        var wasCalled = false
        var countKey = "per"
        var perPage = 20
        var pageKey = "page"
        var firstPage = 1
        let call = CombineNetCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), Endpoint())
        call.firingFunc = { _ in wasCalled = true }
        
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        
        let strings = [""]
        
        let pipeline: ([String], [String]) -> [String] = call.pagedModelsPipeline()
        
        XCTAssertEqual(pipeline(strings, strings).count, 1)
        
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        
        XCTAssertEqual(pipeline(strings, strings).count, 2)
    }
    
    func testManagedModels() throws {
        class ModelHolder {
            var strings: [String]?
        }
        let holder = ModelHolder()
        
        var wasCalled = false
        var countKey = "per"
        var perPage = 20
        var pageKey = "page"
        var firstPage = 1
        let strings = [""]
        let call = CombineNetCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), Endpoint())
        call.firingFunc = { fireable in fireable.responder.dataHandler(Data()) }
        
        call.managePagedModels(on: holder, atKeyPath: \.strings, parser: { _ in strings }).store(in: &cancelBag)
        
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        XCTAssertEqual(holder.strings?.count, 1)
        
        call.nextPage(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        XCTAssertEqual(holder.strings?.count, 2)
        
        call.resetAndFire()
        XCTAssertEqual(holder.strings?.count, 1)
    }
    
    func testTableView() throws {
        var wasCalled = false
        var countKey = "per"
        var perPage = 20
        var pageKey = "page"
        var firstPage = 1
        let call = CombineNetCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), Endpoint())
        call.firingFunc = { _ in wasCalled = true }
        
        let mockTV = MockTableView()
        mockTV.previousRow = 54
        mockTV.numberOfRows = 60
        
        let pager: (UITableViewCell, UITableView, IndexPath) -> Void = call.pager(pageSize: 30, pageTrigger: 4)
        
        pager(UITableViewCell(), mockTV, IndexPath(row: 55, section: 0))
        XCTAssertFalse(wasCalled)
        
        mockTV.previousRow = 55
        pager(UITableViewCell(), mockTV, IndexPath(row: 56, section: 0))
        XCTAssert(wasCalled)
    }
}

class MockTableView: UITableView {
    var previousRow: Int?
    var numberOfRows: Int?
    override var indexPathsForVisibleRows: [IndexPath]? { return [IndexPath(row: previousRow!, section: 0)] }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return numberOfRows ?? 0
    }
}
