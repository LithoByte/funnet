//
//  RequestTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 3/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import FunNet
import LithoOperators

class RequestTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testEndpointUrl() {
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api.v2", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.url?.absoluteString, "http://api.lithobyte.co/api.v2/apps")
    }

    func testGet() {
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testPost() {
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        endpoint /> setToPost
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.httpMethod, "POST")
    }

    func testPut() {
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        endpoint /> setToPut
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.httpMethod, "PUT")
    }

    func testPatch() {
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        endpoint /> setToPatch
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.httpMethod, "PATCH")
    }

    func testDelete() {
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        endpoint /> setToDelete
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.httpMethod, "DELETE")
    }
    
    func testHeaders() {
        let headers = ["X-Api-Key": "akljsdfhgafdga"]
        let serverConfig = ServerConfiguration(shouldStub: true, scheme: "http", host: "api.lithobyte.co", apiRoute: "api/v1", urlConfiguration: URLSessionConfiguration.default)
        var endpoint = Endpoint()
        endpoint.path = "apps"
        endpoint.addHeaders(headers: headers)
        
        let request = generateRequest(from: serverConfig, endpoint: endpoint)
        
        XCTAssertEqual(request.allHTTPHeaderFields, headers)
    }
}
