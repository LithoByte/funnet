import XCTest
import FunNetCore
@testable import APITester

final class ServerConfigurationExtensionsTests: XCTestCase {
    func testIdDerivedFromSchemeHostAndApiBaseRoute() {
        let a = ServerConfiguration(scheme: "https", host: "api.example.com", apiRoute: "v1")
        let b = ServerConfiguration(scheme: "https", host: "api.example.com", apiRoute: "v1")
        let c = ServerConfiguration(scheme: "http",  host: "api.example.com", apiRoute: "v1")
        let d = ServerConfiguration(scheme: "https", host: "other.example.com", apiRoute: "v1")
        let e = ServerConfiguration(scheme: "https", host: "api.example.com", apiRoute: "v2")

        XCTAssertEqual(a.id, b.id)
        XCTAssertNotEqual(a.id, c.id)
        XCTAssertNotEqual(a.id, d.id)
        XCTAssertNotEqual(a.id, e.id)
    }

    func testEqualityComparesPersistedFields() {
        let a = ServerConfiguration(shouldStub: false, shouldUseCookies: true,
                                    scheme: "https", host: "h", apiRoute: "v1")
        let b = ServerConfiguration(shouldStub: false, shouldUseCookies: true,
                                    scheme: "https", host: "h", apiRoute: "v1")
        XCTAssertEqual(a, b)

        let c = ServerConfiguration(shouldStub: true, shouldUseCookies: true,
                                    scheme: "https", host: "h", apiRoute: "v1")
        XCTAssertNotEqual(a, c)
    }

    func testCopyProducesIndependentInstance() {
        let original = ServerConfiguration(shouldStub: false, shouldUseCookies: true,
                                           scheme: "https", host: "h", apiRoute: "v1")
        let copy = original.copy()

        XCTAssertTrue(original !== copy)
        XCTAssertEqual(original, copy)
        XCTAssertEqual(original.id, copy.id)
    }
}
