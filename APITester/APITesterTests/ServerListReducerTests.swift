import XCTest
import ComposableArchitecture
import FunNetCore
@testable import APITester

@MainActor
final class ServerListReducerTests: XCTestCase {
    func testDidChangeScenePhaseLoadsServers() async {
        let server = ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1")
        let state = ServerListReducer.State()
        let store = TestStore(initialState: state) {
            ServerListReducer()
        } withDependencies: {
            $0.serverStore.load = { [server] }
        }
        await store.send(.didChangeScenePhase) {
            $0.allServers = IdentifiedArray(uniqueElements: [server])
        }
    }

    func testAddNewTappedPresentsCreateEditor() async {
        let store = TestStore(initialState: ServerListReducer.State()) {
            ServerListReducer()
        }
        await store.send(.addNewTapped) {
            let blank = ServerConfiguration(scheme: "https", host: "", apiRoute: nil)
            $0.editor = EditServerReducer.State(mode: .create, original: blank,
                                                 scheme: "https", host: "", apiBaseRoute: "")
        }
    }

    func testEditorDidSaveCreateAppendsAndPersists() async {
        var saved: [ServerConfiguration] = []
        var state = ServerListReducer.State()
        let blank = ServerConfiguration(scheme: "https", host: "", apiRoute: nil)
        state.editor = EditServerReducer.State(mode: .create, original: blank,
                                                scheme: "https", host: "", apiBaseRoute: "")
        let store = TestStore(initialState: state) {
            ServerListReducer()
        } withDependencies: {
            $0.serverStore.save = { saved = $0 }
        }
        let newServer = ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1")
        store.exhaustivity = .off
        await store.send(.editor(.presented(.delegate(.didSaveCreate(newServer)))))
        await store.finish()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.host, "h")
    }

    func testServerEditWithIdChangeMigratesEndpoints() async {
        let original = ServerConfiguration(scheme: "https", host: "old", apiRoute: "v1")
        let originalId = original.id
        let updated = ServerConfiguration(scheme: "https", host: "new", apiRoute: "v1")
        let updatedId = updated.id

        var migratedFrom: ServerConfiguration.ID?
        var migratedTo: ServerConfiguration.ID?

        var state = ServerListReducer.State()
        state.allServers = [original]
        state.editor = EditServerReducer.State(mode: .edit(originalId: originalId), original: original,
                                                scheme: "https", host: "old", apiBaseRoute: "v1")

        let store = TestStore(initialState: state) {
            ServerListReducer()
        } withDependencies: {
            $0.serverStore.save = { _ in }
            $0.endpointStore.migrate = { from, to in
                migratedFrom = from
                migratedTo = to
            }
        }
        store.exhaustivity = .off
        await store.send(.editor(.presented(.delegate(.didSaveEdit(originalId: originalId, updated)))))
        await store.finish()
        XCTAssertEqual(migratedFrom, originalId)
        XCTAssertEqual(migratedTo, updatedId)
    }

    func testServerDeleteRemovesAndDeletesEndpoints() async {
        let server = ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1")
        var state = ServerListReducer.State()
        state.allServers = [server]

        var deleted: ServerConfiguration.ID?
        let store = TestStore(initialState: state) {
            ServerListReducer()
        } withDependencies: {
            $0.serverStore.save = { _ in }
            $0.endpointStore.delete = { deleted = $0 }
        }
        store.exhaustivity = .off
        await store.send(.server(server.id, .deleteTapped))
        await store.finish()
        XCTAssertEqual(deleted, server.id)
    }
}
