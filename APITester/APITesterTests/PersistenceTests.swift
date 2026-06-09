import XCTest
import FunNetCore
@testable import APITester

final class PersistenceTests: XCTestCase {
    var defaults: UserDefaults!
    let suiteName = "FunNetTests-\(UUID().uuidString)"

    override func setUp() {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testPersistedServerConfigurationRoundTrip() throws {
        let s = ServerConfiguration(shouldStub: true, shouldUseCookies: false,
                                    scheme: "https", host: "h", apiRoute: "v1")
        let persisted = PersistedServerConfiguration(s)
        let data = try JSONEncoder().encode(persisted)
        let decoded = try JSONDecoder().decode(PersistedServerConfiguration.self, from: data)
        let restored = decoded.toServerConfiguration()

        XCTAssertEqual(restored.scheme, "https")
        XCTAssertEqual(restored.host, "h")
        XCTAssertEqual(restored.apiBaseRoute, "v1")
        XCTAssertEqual(restored.shouldStub, true)
        XCTAssertEqual(restored.shouldUseCookies, false)
    }

    func testServerStoreSaveLoadRoundTrip() {
        let store = makeServerStore(defaults: defaults)
        let s1 = ServerConfiguration(scheme: "https", host: "a", apiRoute: nil)
        let s2 = ServerConfiguration(scheme: "http",  host: "b", apiRoute: "v2")

        store.save([s1, s2])
        let loaded = store.load()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].host, "a")
        XCTAssertEqual(loaded[1].host, "b")
        XCTAssertEqual(loaded[1].apiBaseRoute, "v2")
    }

    func testServerStoreLoadWithNoDataReturnsEmpty() {
        let store = makeServerStore(defaults: defaults)
        XCTAssertEqual(store.load().count, 0)
    }

    func testEndpointStoreSaveLoadPerServer() {
        let store = makeEndpointStore(defaults: defaults)
        let serverID: Int = 42

        var e = Endpoint(); e.path = "users"; e.httpMethod = "GET"

        store.save([e], serverID)
        let loaded = store.load(serverID)

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].path, "users")
    }

    func testEndpointStoreIsolatedPerServer() {
        let store = makeEndpointStore(defaults: defaults)

        var e1 = Endpoint(); e1.path = "a"
        var e2 = Endpoint(); e2.path = "b"

        store.save([e1], 1)
        store.save([e2], 2)

        XCTAssertEqual(store.load(1).first?.path, "a")
        XCTAssertEqual(store.load(2).first?.path, "b")
    }

    func testEndpointStoreMigrate() {
        let store = makeEndpointStore(defaults: defaults)

        var e = Endpoint(); e.path = "x"
        store.save([e], 100)

        store.migrate(100, 200)

        XCTAssertEqual(store.load(100).count, 0)
        XCTAssertEqual(store.load(200).first?.path, "x")
    }

    func testEndpointStoreDelete() {
        let store = makeEndpointStore(defaults: defaults)

        var e = Endpoint(); e.path = "x"
        store.save([e], 7)

        store.delete(7)

        XCTAssertEqual(store.load(7).count, 0)
    }
}
