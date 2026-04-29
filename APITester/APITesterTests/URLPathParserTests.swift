import XCTest
import Foundation
@testable import APITester

final class URLPathParserTests: XCTestCase {
    func testEmptyInput() {
        let r = parsePathField("")
        XCTAssertEqual(r.path, "")
        XCTAssertTrue(r.getParams.isEmpty)
    }

    func testPathOnly() {
        let r = parsePathField("users")
        XCTAssertEqual(r.path, "users")
        XCTAssertTrue(r.getParams.isEmpty)
    }

    func testPathWithLeadingSlashIsStripped() {
        let r = parsePathField("/users")
        XCTAssertEqual(r.path, "users")
    }

    func testTrailingQuestionMarkOnly() {
        let r = parsePathField("users?")
        XCTAssertEqual(r.path, "users")
        XCTAssertTrue(r.getParams.isEmpty)
    }

    func testSingleQueryItem() {
        let r = parsePathField("users?a=1")
        XCTAssertEqual(r.path, "users")
        XCTAssertEqual(r.getParams, [URLQueryItem(name: "a", value: "1")])
    }

    func testMultipleQueryItems() {
        let r = parsePathField("users?a=1&b=2")
        XCTAssertEqual(r.path, "users")
        XCTAssertEqual(r.getParams, [URLQueryItem(name: "a", value: "1"),
                                     URLQueryItem(name: "b", value: "2")])
    }

    func testDuplicateKeysPreserveOrder() {
        let r = parsePathField("users?a=1&a=2")
        XCTAssertEqual(r.path, "users")
        XCTAssertEqual(r.getParams, [URLQueryItem(name: "a", value: "1"),
                                     URLQueryItem(name: "a", value: "2")])
    }

    func testFragmentIsDropped() {
        let r = parsePathField("users#section")
        XCTAssertEqual(r.path, "users")
        XCTAssertTrue(r.getParams.isEmpty)
    }

    func testNestedPathIsPreserved() {
        let r = parsePathField("users/42/posts?limit=10")
        XCTAssertEqual(r.path, "users/42/posts")
        XCTAssertEqual(r.getParams, [URLQueryItem(name: "limit", value: "10")])
    }
}
