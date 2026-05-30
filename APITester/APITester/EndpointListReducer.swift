import Foundation
import ComposableArchitecture
import FunNetCore

enum EndpointRowAction: Equatable {
    case tapped
    case duplicateTapped
    case deleteTapped
}

@Reducer
struct EndpointListReducer {
    @Dependency(\.endpointStore) var endpointStore

    @ObservableState
    struct State: Equatable {
        var server: ServerConfiguration
        var allEndpoints: IdentifiedArrayOf<Endpoint> = .init()
        var localFilter: String = ""
        @Presents var editor: EditEndpointReducer.State?

        var displayedEndpoints: IdentifiedArrayOf<Endpoint> {
            guard !localFilter.isEmpty else { return allEndpoints }
            return IdentifiedArray(uniqueElements: allEndpoints.filter {
                $0.path.localizedCaseInsensitiveContains(localFilter)
            })
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addNewTapped
        case didChangeScenePhase
        case endpoint(Endpoint.ID, EndpointRowAction)
        case editor(PresentationAction<EditEndpointReducer.Action>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .didChangeScenePhase:
                let loaded = endpointStore.load(state.server.id)
                state.allEndpoints = IdentifiedArray(uniqueElements: loaded)
                return .none

            case .addNewTapped:
                state.editor = EditEndpointReducer.State(mode: .create, endpoint: Endpoint(), server: state.server)
                return .none

            case .endpoint(let id, .tapped):
                guard let endpoint = state.allEndpoints[id: id] else { return .none }
                state.editor = EditEndpointReducer.State(mode: .edit(originalId: id),
                                                          endpoint: endpoint,
                                                          server: state.server)
                return .none

            case .endpoint(let id, .duplicateTapped):
                guard let endpoint = state.allEndpoints[id: id] else { return .none }
                state.editor = EditEndpointReducer.State(mode: .duplicate,
                                                          endpoint: endpoint,
                                                          server: state.server)
                return .none

            case .endpoint(let id, .deleteTapped):
                state.allEndpoints.remove(id: id)
                endpointStore.save(Array(state.allEndpoints), state.server.id)
                return .none

            case .editor(.presented(.delegate(.didSaveCreate(let endpoint)))):
                state.allEndpoints.append(endpoint)
                endpointStore.save(Array(state.allEndpoints), state.server.id)
                state.editor = nil
                return .none

            case .editor(.presented(.delegate(.didSaveEdit(let originalId, let endpoint)))):
                if let index = state.allEndpoints.index(id: originalId) {
                    state.allEndpoints.remove(at: index)
                    state.allEndpoints.insert(endpoint, at: index)
                }
                endpointStore.save(Array(state.allEndpoints), state.server.id)
                state.editor = nil
                return .none

            case .editor(.presented(.delegate(.didCancel))):
                state.editor = nil
                return .none

            case .editor:
                return .none
            }
        }
        .ifLet(\.$editor, action: \.editor) {
            EditEndpointReducer()
        }
    }
}
