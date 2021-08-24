//
//  ServerConfigurationTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 3/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import LithoOperators
import Prelude
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
    
    func testPreviouslyEncodedGetParameters() {
        let url = dictionaryToUrlUnencodedParams(dict: ["page": 1, "key": "api%20key"])
        XCTAssert(url == "key=api%20key&page=1" || url == "page=1&key=api%20key")
    }
    
    func testNoCookiePolicy() {
        let config = ServerConfiguration(shouldUseCookies: false, host: "lithobyte.co", apiRoute: "api/v1")
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.removeCookies(since: Calendar.current.date(byAdding: .year, value: -20, to: Date())!)
        let cookieProps: [HTTPCookiePropertyKey: Any] = [
            .domain: "https://lithobyte.co",
            .path: "/",
            .name: "name",
            .value: "value",
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 10000)
        ]

        if let cookie = HTTPCookie(properties: cookieProps) {
            cookieStorage.setCookie(cookie)
        } else {
            XCTFail("Could not instantiate cookie")
        }
        XCTAssertNotNil(cookieStorage.cookies?.count)
        XCTAssertEqual(cookieStorage.cookies!.count, 1)
        
        config.shouldUseCookies |> applyCookiePolicy
        
        XCTAssert(cookieStorage.cookies?.count == nil || cookieStorage.cookies!.count == 0)
    }
    
    func testCookiePolicy() {
        let config = ServerConfiguration(shouldUseCookies: true, host: "lithobyte.co", apiRoute: "api/v1")
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.removeCookies(since: Calendar.current.date(byAdding: .year, value: -20, to: Date())!)
        let cookieProps: [HTTPCookiePropertyKey: Any] = [
            .domain: "https://lithobyte.co",
            .path: "/",
            .name: "name",
            .value: "value",
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 10000)
        ]

        if let cookie = HTTPCookie(properties: cookieProps) {
            cookieStorage.setCookie(cookie)
        } else {
            XCTFail("Could not instantiate cookie")
        }
        XCTAssertNotNil(cookieStorage.cookies?.count)
        XCTAssertEqual(cookieStorage.cookies!.count, 1)
        config.shouldUseCookies |> applyCookiePolicy
        
        XCTAssert(cookieStorage.cookies?.count != nil && cookieStorage.cookies!.count != 0)
    }
}
