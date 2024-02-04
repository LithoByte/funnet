//
//  CurlTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 6/13/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import FunNet

class CurlTests: XCTestCase {
    func testUrl() throws {
        let url = URL(string: "https://lithobyte.co/api/v1/apps")
        var request = URLRequest(url: url!)
        
        XCTAssertEqual(request.cURL(), "curl -X GET '\(url!.absoluteString)' ")
    }
    
    func testHeaders() {
        let url = URL(string: "https://lithobyte.co/api/v1/apps")
        var request = URLRequest(url: url!)
        request.addHeaders(["Accept": "application/json"])
        
        XCTAssertEqual(request.cURL(), "curl -X GET '\(url!.absoluteString)' -H 'Accept: application/json' ")
    }
    
    func testMethod() throws {
        let url = URL(string: "https://lithobyte.co/api/v1/apps")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        XCTAssertEqual(request.cURL(), "curl -X POST '\(url!.absoluteString)' ")
    }
    
    func testBody() throws {
        let url = URL(string: "https://lithobyte.co/api/v1/apps")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = "{\"name\": \"SUBWAY:NYC\"}".data(using: .utf8)
        
        XCTAssertEqual(request.cURL(), "curl -X POST '\(url!.absoluteString)' --data '{\"name\": \"SUBWAY:NYC\"}'")
    }
    
    func testAll() {
        let url = URL(string: "https://lithobyte.co/api/v1/apps")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = "{\"name\": \"SUBWAY:NYC\"}".data(using: .utf8)
        request.addHeaders(["Accept": "application/json"])
        
        XCTAssertEqual(request.cURL(), "curl -X POST '\(url!.absoluteString)' -H 'Accept: application/json' --data '{\"name\": \"SUBWAY:NYC\"}'")
        
    }
}
