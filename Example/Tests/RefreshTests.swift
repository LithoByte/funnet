//
//  RefreshTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 6/12/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import Combine
import FunNet

class RefreshTests: XCTestCase {
    func testTVRefresh() throws {
        var wasCalled = false
        var wasReset = false
        let tableView = UITableView()
        var cancelBag = Set<AnyCancellable>()
        let call = CombineNetCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), Endpoint())
        call.reset = { _ in wasReset = true }
        call.firingFunc = { _ in wasCalled = true }
        
        call.refresh(from: tableView, &cancelBag)
        tableView.refreshControl?.sendActions(for: .valueChanged)
        
        XCTAssertNotNil(tableView.refreshControl)
        XCTAssert(wasReset)
        XCTAssert(wasCalled)
    }
    
    func testCVRefresh() throws {
        var wasCalled = false
        var wasReset = false
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        var cancelBag = Set<AnyCancellable>()
        let call = CombineNetCall(configuration: ServerConfiguration(host: "api.lithobyte.co", apiRoute: nil), Endpoint())
        call.reset = { _ in wasReset = true }
        call.firingFunc = { _ in wasCalled = true }
        
        call.refresh(from: collectionView, &cancelBag)
        collectionView.refreshControl?.sendActions(for: .valueChanged)
        
        XCTAssertNotNil(collectionView.refreshControl)
        XCTAssert(wasReset)
        XCTAssert(wasCalled)
    }
}
