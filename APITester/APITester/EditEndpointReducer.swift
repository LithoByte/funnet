import Foundation
import ComposableArchitecture
import FunNetCore
import FunNetTCA

@Reducer
struct EditEndpointReducer {
    enum Mode: Equatable {
        case create
        case edit(originalId: Endpoint.ID)
        case duplicate
    }

    @ObservableState
    struct State: Equatable {
        var mode: Mode
        var endpoint: Endpoint
        var original: Endpoint
        var pathField: String
        var server: ServerConfiguration
        var netCall: NetCallReducer.State
        @Presents var headerEdit: HeaderEditReducer.State?
        @Presents var response: ResponseReducer.State?

        var canFire: Bool { !endpoint.path.isEmpty || !pathField.isEmpty }

        var canSave: Bool {
            let parsed = parsePathField(pathField)
            var candidate = endpoint
            candidate.path = parsed.path
            candidate.getParams = parsed.getParams
            return candidate != original
        }

        init(mode: Mode, endpoint: Endpoint, server: ServerConfiguration) {
            self.mode = mode
            self.endpoint = endpoint
            self.original = endpoint
            self.pathField = endpoint.path
            self.server = server.copy()
            self.netCall = NetCallReducer.State(
                session: URLSession(configuration: server.urlConfiguration),
                baseUrl: server.toBaseURL(),
                endpoint: endpoint
            )
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case methodPicked(HttpMethod)
        case bodyChanged(String)
        case headerCapsuleTapped(key: String)
        case addHeaderTapped
        case fireTapped
        case saveTapped
        case cancelTapped
        case headerEdit(PresentationAction<HeaderEditReducer.Action>)
        case response(PresentationAction<ResponseReducer.Action>)
        case netCall(NetCallReducer.Action)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case didSaveCreate(Endpoint)
            case didSaveEdit(originalId: Endpoint.ID, Endpoint)
            case didCancel
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.netCall, action: \.netCall) {
            NetCallReducer()
        }
        Reduce(core)
            .ifLet(\.$headerEdit, action: \.headerEdit) {
                HeaderEditReducer()
            }
            .ifLet(\.$response, action: \.response) {
                ResponseReducer()
            }
    }

    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding:
            return .none

        case .methodPicked(let method):
            state.endpoint.method = method
            return .none

        case .bodyChanged(let text):
            state.endpoint.postData = text.isEmpty ? nil : Data(text.utf8)
            return .none

        case .headerCapsuleTapped(let key):
            let value = state.endpoint.httpHeaders[key] ?? ""
            state.headerEdit = HeaderEditReducer.State(existingKey: key, key: key, value: value)
            return .none

        case .addHeaderTapped:
            state.headerEdit = HeaderEditReducer.State(existingKey: nil, key: "", value: "")
            return .none

        case .fireTapped:
            let parsed = parsePathField(state.pathField)
            state.endpoint.path = parsed.path
            state.endpoint.getParams = parsed.getParams
            state.netCall.endpoint = state.endpoint
            return .send(.netCall(.fire))

        case .saveTapped:
            let parsed = parsePathField(state.pathField)
            var candidate = state.endpoint
            candidate.path = parsed.path
            candidate.getParams = parsed.getParams
            guard candidate != state.original else { return .none }
            state.endpoint = candidate
            switch state.mode {
            case .create, .duplicate:
                return .send(.delegate(.didSaveCreate(candidate)))
            case .edit(let originalId):
                return .send(.delegate(.didSaveEdit(originalId: originalId, candidate)))
            }

        case .cancelTapped:
            return .send(.delegate(.didCancel))

        case .headerEdit(.presented(.delegate(let delegateAction))):
            return handleHeaderEditDelegate(&state, delegateAction)

        case .headerEdit:
            return .none

        case .netCall(.delegate(let delegateAction)):
            return handleNetCallDelegate(&state, delegateAction)

        case .netCall:
            return .none

        case .response(.presented(.dismiss)):
            state.response = nil
            return .none

        case .response:
            return .none

        case .delegate:
            return .none
        }
    }

    private func handleHeaderEditDelegate(
        _ state: inout State,
        _ action: HeaderEditReducer.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .save(let originalKey, let key, let value):
            if let originalKey, originalKey != key {
                state.endpoint.httpHeaders.removeValue(forKey: originalKey)
            }
            state.endpoint.httpHeaders[key] = value
            state.headerEdit = nil
            return .none
        case .delete(let key):
            state.endpoint.httpHeaders.removeValue(forKey: key)
            state.headerEdit = nil
            return .none
        case .cancel:
            state.headerEdit = nil
            return .none
        }
    }

    private func handleNetCallDelegate(
        _ state: inout State,
        _ action: NetCallReducer.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .httpResponse(let httpResponse):
            state.response = ResponseReducer.State.from(httpResponse: httpResponse)
            return .none
        case .responseData(let data):
            if state.response != nil {
                state.response?.body = data
            } else {
                state.response = ResponseReducer.State(statusCode: nil, headers: [], body: data, error: nil)
            }
            return .none
        case .error(let error):
            let nsError = error as NSError
            if state.response != nil {
                state.response?.error = nsError
            } else {
                state.response = ResponseReducer.State(statusCode: nil, headers: [], body: nil, error: nsError)
            }
            return .none
        }
    }
}
