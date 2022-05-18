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
    
    func testBaseUrl() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "/api/v1")
        
        let url = config.toBaseURL().url?.absoluteString
        
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1")
    }

    func testSlashPrependedPathParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "/api/v1")
        var endpoint = Endpoint()
        endpoint.path = "/path"
        
        let url = config.url(for: endpoint)?.absoluteString
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1/path")
    }

    func testSlashPrependedApiRouteParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "/api/v1")
        
        let url = config.toBaseURL().url?.absoluteString
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1")
    }

    func testSlashAppendedApiRouteParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "api/v1/")
        
        let url = config.toBaseURL().url?.absoluteString
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1/")
    }
    
    func testMinimalSlashesApiRouteParsesCorrectly() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "api/v1/")
        
        let url = config.toBaseURL().url?.absoluteString
        XCTAssertEqual(url, "https://test.lithobyte.co/api/v1/")
    }
    
    func testEncodedGetParameters() {
        let config = ServerConfiguration(host: "test.lithobyte.co", apiRoute: "api/v1")
        var endpoint = Endpoint()
        endpoint.path = "/search"
        endpoint.getParams = [URLQueryItem(name: "query", value: "true love"), URLQueryItem(name: "page", value: "1")]
        
        let url = config.url(for: endpoint)?.absoluteString
        XCTAssert(url == "https://test.lithobyte.co/api/v1/search?query=true%20love&page=1" || url == "https://test.lithobyte.co/api/v1/search?page=1&query=true%20love")
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
        
        generateRequest(from: config, endpoint: Endpoint())
        
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
        
        generateRequest(from: config, endpoint: Endpoint())
        
        XCTAssert(cookieStorage.cookies?.count != nil && cookieStorage.cookies!.count != 0)
    }
}
