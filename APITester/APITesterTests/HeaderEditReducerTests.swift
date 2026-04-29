import XCTest
import ComposableArchitecture
@testable import APITester

@MainActor
final class HeaderEditReducerTests: XCTestCase {
    func testQuickContentTypeJSONFillsKeyAndValue() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: nil, key: "", value: "")) {
            HeaderEditReducer()
        }
        await store.send(.quickContentTypeJSONTapped) {
            $0.key = "Content-Type"
            $0.value = "application/json"
        }
    }

    func testQuickAcceptJSONFillsKeyAndValue() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: nil, key: "", value: "")) {
            HeaderEditReducer()
        }
        await store.send(.quickAcceptJSONTapped) {
            $0.key = "Accept"
            $0.value = "application/json"
        }
    }

    func testQuickAuthBearerFillsKeyAndStartsValue() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: nil, key: "", value: "")) {
            HeaderEditReducer()
        }
        await store.send(.quickAuthBearerTapped) {
            $0.key = "Authorization"
            $0.value = "Bearer "
        }
    }

    func testSaveDelegatesUpsertForExistingHeader() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: "X-Old",
                                                                     key: "X-New",
                                                                     value: "v")) {
            HeaderEditReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.save(originalKey: "X-Old", key: "X-New", value: "v")))
    }

    func testSaveDelegatesCreateForNewHeader() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: nil,
                                                                     key: "X-New",
                                                                     value: "v")) {
            HeaderEditReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.save(originalKey: nil, key: "X-New", value: "v")))
    }

    func testDeleteDelegatesDeletion() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: "X-Gone",
                                                                     key: "X-Gone",
                                                                     value: "v")) {
            HeaderEditReducer()
        }
        await store.send(.deleteTapped)
        await store.receive(.delegate(.delete(key: "X-Gone")))
    }

    func testCancelDelegatesCancel() async {
        let store = TestStore(initialState: HeaderEditReducer.State(existingKey: nil, key: "", value: "")) {
            HeaderEditReducer()
        }
        await store.send(.cancelTapped)
        await store.receive(.delegate(.cancel))
    }
}
