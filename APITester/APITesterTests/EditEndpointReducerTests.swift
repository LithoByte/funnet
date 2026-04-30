import XCTest
import ComposableArchitecture
import FunNetCore
import FunNetTCA
@testable import APITester

@MainActor
final class EditEndpointReducerTests: XCTestCase {
    func makeServer() -> ServerConfiguration {
        ServerConfiguration(scheme: "https", host: "api.example.com", apiRoute: "v1")
    }

    func makeState(mode: EditEndpointReducer.Mode, endpoint: Endpoint) -> EditEndpointReducer.State {
        EditEndpointReducer.State(mode: mode, endpoint: endpoint, server: makeServer())
    }

    func testSaveCreateDelegatesCreate() async {
        var e = Endpoint(); e.path = "users"
        var state = makeState(mode: .create, endpoint: Endpoint())
        state.endpoint = e
        state.pathField = "users"

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.didSaveCreate(e)))
    }

    func testSaveEditDelegatesEditWithOriginalId() async {
        var original = Endpoint(); original.path = "users"
        let originalId = original.id
        var edited = original; edited.path = "people"

        var state = makeState(mode: .edit(originalId: originalId), endpoint: original)
        state.endpoint = edited
        state.pathField = "people"

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.didSaveEdit(originalId: originalId, edited)))
    }

    func testSaveDuplicateDelegatesCreate() async {
        var source = Endpoint(); source.path = "users"
        var state = makeState(mode: .duplicate, endpoint: source)
        state.pathField = "users"

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.saveTapped)
        await store.receive(.delegate(.didSaveCreate(source)))
    }

    func testSaveNoOpWhenUnchanged() async {
        var endpoint = Endpoint(); endpoint.path = "users"
        let state = makeState(mode: .edit(originalId: endpoint.id), endpoint: endpoint)

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.saveTapped)
    }

    func testFireWritesParsedPathAndQueryParams() async {
        let endpoint = Endpoint()
        var state = makeState(mode: .create, endpoint: endpoint)
        state.pathField = "users?page=2"

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        store.exhaustivity = .off
        await store.send(.fireTapped) {
            $0.endpoint.path = "users"
            $0.endpoint.getParams = [URLQueryItem(name: "page", value: "2")]
        }
    }

    func testHttpResponsePopulatesResponseSheet() async {
        let endpoint = Endpoint()
        let state = makeState(mode: .create, endpoint: endpoint)
        let url = URL(string: "https://x")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.netCall(.delegate(.httpResponse(httpResponse)))) {
            $0.response = ResponseReducer.State.from(httpResponse: httpResponse)
        }
    }

    func testResponseDataAppendedAfterHttpResponse() async {
        let endpoint = Endpoint()
        var state = makeState(mode: .create, endpoint: endpoint)
        let url = URL(string: "https://x")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        state.response = ResponseReducer.State.from(httpResponse: httpResponse)

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        let body = Data("{}".utf8)
        await store.send(.netCall(.delegate(.responseData(body)))) {
            $0.response?.body = body
        }
    }

    func testErrorWithoutPriorResponseCreatesErrorOnlyState() async {
        let endpoint = Endpoint()
        let state = makeState(mode: .create, endpoint: endpoint)

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        let err = NSError(domain: "Server", code: 500)
        await store.send(.netCall(.delegate(.error(err)))) {
            $0.response = ResponseReducer.State(statusCode: nil, headers: [], body: nil, error: err)
        }
    }

    func testHeaderEditSaveUpsertsIntoEndpointHeaders() async {
        let endpoint = Endpoint()
        var state = makeState(mode: .create, endpoint: endpoint)
        state.headerEdit = HeaderEditReducer.State(existingKey: nil, key: "X-K", value: "V")

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.headerEdit(.presented(.delegate(.save(originalKey: nil,
                                                                  key: "X-K",
                                                                  value: "V"))))) {
            $0.endpoint.httpHeaders["X-K"] = "V"
        }
    }

    func testHeaderEditDeleteRemovesHeader() async {
        var endpoint = Endpoint(); endpoint.httpHeaders = ["X-K": "V"]
        var state = makeState(mode: .create, endpoint: endpoint)
        state.headerEdit = HeaderEditReducer.State(existingKey: "X-K", key: "X-K", value: "V")

        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.headerEdit(.presented(.delegate(.delete(key: "X-K"))))) {
            $0.endpoint.httpHeaders.removeValue(forKey: "X-K")
        }
    }

    func testCancelDelegatesCancel() async {
        let state = makeState(mode: .create, endpoint: Endpoint())
        let store = TestStore(initialState: state) {
            EditEndpointReducer()
        }
        await store.send(.cancelTapped)
        await store.receive(.delegate(.didCancel))
    }
}
