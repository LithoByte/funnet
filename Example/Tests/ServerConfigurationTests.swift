//
//  ServerConfigurationTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 3/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import FunNet

class ServerConfigurationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSlashPrependedPathParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "api/v1")
        
        let url = config.urlString(for: "/path", getParams: [:])
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1/path")
    }

    func testSlashPrependedApiRouteParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "/api/v1")
        
        let url = config.toBaseUrlString()
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1/")
    }

    func testSlashAppendedApiRouteParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "api/v1/")
        
        let url = config.toBaseUrlString()
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1/")
    }

    func testEncodedGetParameters() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "api/v1")
        
        let url = config.urlString(for: "search", getParams: ["query": "true love", "page": 1])
        XCTAssert(url == "https://test.lithobyte.co/api/v1/search?query=true%20love&page=1" || url == "https://test.lithobyte.co/api/v1/search?page=1&query=true%20love")
    }
}
