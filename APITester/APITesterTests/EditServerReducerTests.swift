import XCTest
import ComposableArchitecture
import FunNetCore
@testable import APITester

@MainActor
final class EditServerReducerTests: XCTestCase {
    func testSaveCreateDelegatesCreate() async {
        let state = EditServerReducer.State(mode: .create,
                                             original: ServerConfiguration(scheme: "https", host: "", apiRoute: nil),
                                             scheme: "https", host: "h", apiBaseRoute: "v1")
        let store = TestStore(initialState: state) {
            EditServerReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.didSaveCreate(ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1"))))
    }

    func testSaveEditDelegatesEdit() async {
        let originalServer = ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1")
        let originalId = originalServer.id
        let state = EditServerReducer.State(mode: .edit(originalId: originalId),
                                             original: originalServer,
                                             scheme: "https", host: "h2", apiBaseRoute: "v1")
        let store = TestStore(initialState: state) {
            EditServerReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.didSaveEdit(originalId: originalId,
                                                   ServerConfiguration(scheme: "https", host: "h2", apiRoute: "v1"))))
    }

    func testSaveNoOpWhenNoChanges() async {
        let original = ServerConfiguration(scheme: "https", host: "h", apiRoute: "v1")
        let state = EditServerReducer.State(mode: .edit(originalId: original.id),
                                             original: original,
                                             scheme: "https", host: "h", apiBaseRoute: "v1")
        let store = TestStore(initialState: state) {
            EditServerReducer()
        }
        await store.send(.saveTapped)
    }

    func testCancelDelegatesCancel() async {
        let state = EditServerReducer.State(mode: .create,
                                             original: ServerConfiguration(scheme: "https", host: "", apiRoute: nil),
                                             scheme: "https", host: "", apiBaseRoute: "")
        let store = TestStore(initialState: state) {
            EditServerReducer()
        }
        await store.send(.cancelTapped)
        await store.receive(.delegate(.didCancel))
    }
}
