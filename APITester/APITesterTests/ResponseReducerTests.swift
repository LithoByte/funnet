import XCTest
@testable import APITester

final class ResponseReducerTests: XCTestCase {
    func testPrettyPrintValidJSONObject() {
        let raw = Data("{\"b\":2,\"a\":1}".utf8)
        let pretty = prettyPrintJSON(raw)
        XCTAssertNotNil(pretty)
        XCTAssertTrue(pretty!.contains("\n"))
        XCTAssertTrue(pretty!.contains("\"a\""))
        XCTAssertTrue(pretty!.contains("\"b\""))
    }

    func testPrettyPrintValidJSONArray() {
        let raw = Data("[1,2,3]".utf8)
        let pretty = prettyPrintJSON(raw)
        XCTAssertNotNil(pretty)
        XCTAssertTrue(pretty!.contains("\n"))
    }

    func testPrettyPrintInvalidJSONReturnsNil() {
        let raw = Data("not json".utf8)
        XCTAssertNil(prettyPrintJSON(raw))
    }

    func testRenderBodyJSONRendersPretty() {
        let raw = Data("{\"a\":1}".utf8)
        let rendered = renderBody(raw)
        XCTAssertTrue(rendered.contains("\n"))
        XCTAssertTrue(rendered.contains("\"a\""))
    }

    func testRenderBodyNonJSONUtf8RendersRaw() {
        let raw = Data("hello world".utf8)
        XCTAssertEqual(renderBody(raw), "hello world")
    }

    func testRenderBodyNilReturnsEmpty() {
        XCTAssertEqual(renderBody(nil), "")
    }

    func testRenderBodyBinaryReturnsBytePlaceholder() {
        let raw = Data([0xFF, 0xFE, 0x00, 0x01])
        let rendered = renderBody(raw)
        XCTAssertTrue(rendered.contains("4 bytes"))
    }
}
