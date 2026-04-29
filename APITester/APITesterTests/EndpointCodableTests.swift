import XCTest
import FunNetCore
@testable import APITester

final class EndpointCodableTests: XCTestCase {
    func testRoundTripPreservesAllCodableFields() throws {
        var e = Endpoint()
        e.httpMethod = "POST"
        e.httpHeaders = ["Content-Type": "application/json", "X-Custom": "abc"]
        e.path = "users/42"
        e.getParams = [URLQueryItem(name: "a", value: "1"), URLQueryItem(name: "b", value: "2")]
        e.timeout = 30
        e.postData = Data("{\"k\":\"v\"}".utf8)

        let data = try JSONEncoder().encode(e)
        let decoded = try JSONDecoder().decode(Endpoint.self, from: data)

        XCTAssertEqual(decoded.httpMethod, "POST")
        XCTAssertEqual(decoded.httpHeaders, ["Content-Type": "application/json", "X-Custom": "abc"])
        XCTAssertEqual(decoded.path, "users/42")
        XCTAssertEqual(decoded.getParams, [URLQueryItem(name: "a", value: "1"), URLQueryItem(name: "b", value: "2")])
        XCTAssertEqual(decoded.timeout, 30)
        XCTAssertEqual(decoded.postData, Data("{\"k\":\"v\"}".utf8))
    }

    func testDataStreamIsNotEncoded() throws {
        var e = Endpoint()
        e.path = "x"
        e.dataStream = InputStream(data: Data())

        let json = try JSONEncoder().encode(e)
        let dict = try JSONSerialization.jsonObject(with: json) as? [String: Any]
        XCTAssertNotNil(dict)
        XCTAssertNil(dict?["dataStream"])
    }

    func testDecodeWithMissingPostDataDecodesNil() throws {
        let json = """
        {"httpMethod":"GET","httpHeaders":{},"path":"x","getParams":[],"timeout":60}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Endpoint.self, from: json)
        XCTAssertNil(decoded.postData)
    }

    func testIdIsContentDerivedAndStable() {
        var e1 = Endpoint()
        e1.path = "x"; e1.httpMethod = "GET"
        e1.httpHeaders = ["A": "1"]
        e1.postData = Data("body".utf8)

        var e2 = Endpoint()
        e2.path = "x"; e2.httpMethod = "GET"
        e2.httpHeaders = ["A": "1"]
        e2.postData = Data("body".utf8)

        XCTAssertEqual(e1.id, e2.id)
    }

    func testIdDiffersWhenContentDiffers() {
        var e1 = Endpoint(); e1.path = "x"
        var e2 = Endpoint(); e2.path = "y"
        XCTAssertNotEqual(e1.id, e2.id)
    }
}
