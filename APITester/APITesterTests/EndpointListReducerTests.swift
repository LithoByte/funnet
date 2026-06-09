import XCTest
import ComposableArchitecture
import FunNetCore
@testable import APITester

@MainActor
final class EndpointListReducerTests: XCTestCase {
    let server = ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1")

    func testDidChangeScenePhaseLoadsEndpoints() async {
        var loaded = false
        var savedEndpoint = Endpoint(); savedEndpoint.path = "users"

        let state = EndpointListReducer.State(server: server)
        let store = TestStore(initialState: state) {
            EndpointListReducer()
        } withDependencies: {
            $0.endpointStore.load = { _ in loaded = true; return [savedEndpoint] }
        }
        await store.send(.didChangeScenePhase) {
            $0.allEndpoints = [savedEndpoint]
        }
        XCTAssertTrue(loaded)
    }

    func testAddNewTappedPushesEditorInCreateMode() async {
        let state = EndpointListReducer.State(server: server)
        let store = TestStore(initialState: state) {
            EndpointListReducer()
        }
        await store.send(.addNewTapped) {
            $0.editor = EditEndpointReducer.State(mode: .create, endpoint: Endpoint(), server: self.server)
        }
    }

    func testEndpointTappedPushesEditorInEditMode() async {
        var endpoint = Endpoint(); endpoint.path = "users"
        var state = EndpointListReducer.State(server: server)
        state.allEndpoints = [endpoint]

        let store = TestStore(initialState: state) {
            EndpointListReducer()
        }
        await store.send(.endpoint(endpoint.id, .tapped)) {
            $0.editor = EditEndpointReducer.State(mode: .edit(originalId: endpoint.id),
                                                   endpoint: endpoint,
                                                   server: self.server)
        }
    }

    func testDuplicateTappedPushesEditorInDuplicateMode() async {
        var endpoint = Endpoint(); endpoint.path = "users"
        var state = EndpointListReducer.State(server: server)
        state.allEndpoints = [endpoint]

        let store = TestStore(initialState: state) {
            EndpointListReducer()
        }
        await store.send(.endpoint(endpoint.id, .duplicateTapped)) {
            $0.editor = EditEndpointReducer.State(mode: .duplicate,
                                                   endpoint: endpoint,
                                                   server: self.server)
        }
    }

    func testEditorDidSaveCreateAppendsAndPersists() async {
        var saved: [Endpoint] = []
        var state = EndpointListReducer.State(server: server)
        state.editor = EditEndpointReducer.State(mode: .create, endpoint: Endpoint(), server: server)
        let store = TestStore(initialState: state) {
            EndpointListReducer()
        } withDependencies: {
            $0.endpointStore.save = { endpoints, _ in saved = endpoints }
        }
        var newEndpoint = Endpoint(); newEndpoint.path = "users"
        store.exhaustivity = .off
        await store.send(.editor(.presented(.delegate(.didSaveCreate(newEndpoint)))))
        await store.finish()
        XCTAssertEqual(saved.first?.path, "users")
    }

    func testEditorDidSaveEditReplacesAndPersists() async {
        var saved: [Endpoint] = []
        var original = Endpoint(); original.path = "users"
        let originalId = original.id

        var state = EndpointListReducer.State(server: server)
        state.allEndpoints = [original]
        state.editor = EditEndpointReducer.State(mode: .edit(originalId: originalId), endpoint: original, server: server)

        let store = TestStore(initialState: state) {
            EndpointListReducer()
        } withDependencies: {
            $0.endpointStore.save = { endpoints, _ in saved = endpoints }
        }
        var updated = original; updated.path = "people"
        store.exhaustivity = .off
        await store.send(.editor(.presented(.delegate(.didSaveEdit(originalId: originalId, updated)))))
        await store.finish()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.path, "people")
    }

    func testEndpointDeletedRemovesAndPersists() async {
        var saved: [Endpoint] = [Endpoint()]
        var endpoint = Endpoint(); endpoint.path = "users"

        var state = EndpointListReducer.State(server: server)
        state.allEndpoints = [endpoint]

        let store = TestStore(initialState: state) {
            EndpointListReducer()
        } withDependencies: {
            $0.endpointStore.save = { endpoints, _ in saved = endpoints }
        }
        store.exhaustivity = .off
        await store.send(.endpoint(endpoint.id, .deleteTapped))
        await store.finish()
        XCTAssertTrue(saved.isEmpty)
    }
}
