import Foundation
import SwiftUI
import ComposableArchitecture
import FunNetCore

private let coffeeURL = URL(string: "https://buymeacoffee.com/schrockblock")!

@Reducer
struct ServerListReducer {
    @Dependency(\.serverStore) var serverStore
    @Dependency(\.endpointStore) var endpointStore
    @Dependency(\.coffeeTipClient) var coffeeTipClient
    @Dependency(\.openURLClient) var openURLClient

    @ObservableState
    struct State: Equatable {
        var allServers: IdentifiedArrayOf<ServerConfiguration> = .init()
        var localFilter: String = ""
        @Presents var editor: EditServerReducer.State?
        @Presents var detail: ServerDetailReducer.State?
        @Presents var coffeeAlert: AlertState<Action.CoffeeAlert>?
        var hasTipped: Bool = false

        var displayedServers: IdentifiedArrayOf<ServerConfiguration> {
            guard !localFilter.isEmpty else { return allServers }
            return IdentifiedArray(uniqueElements: allServers.filter {
                $0.host.localizedCaseInsensitiveContains(localFilter)
            })
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addNewTapped
        case didChangeScenePhase
        case server(ServerConfiguration.ID, ServerItemReducer.Action)
        case editor(PresentationAction<EditServerReducer.Action>)
        case detail(PresentationAction<ServerDetailReducer.Action>)
        case coffeeTapped
        case coffeeAlert(PresentationAction<CoffeeAlert>)

        enum CoffeeAlert: Equatable { case confirm }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .didChangeScenePhase:
                state.allServers = IdentifiedArray(uniqueElements: serverStore.load())
                state.hasTipped = coffeeTipClient.hasTipped()
                return .none

            case .addNewTapped:
                let blank = ServerConfiguration(scheme: "https", host: "", apiRoute: nil)
                state.editor = EditServerReducer.State(mode: .create,
                                                         original: blank,
                                                         scheme: "https",
                                                         host: "",
                                                         apiBaseRoute: "")
                return .none

            case .server(let id, .tapped):
                guard let server = state.allServers[id: id] else { return .none }
                state.detail = ServerDetailReducer.State(server: server)
                return .none

            case .server(let id, .editTapped):
                guard let server = state.allServers[id: id] else { return .none }
                state.editor = EditServerReducer.State(
                    mode: .edit(originalId: id),
                    original: server,
                    scheme: server.scheme,
                    host: server.host,
                    apiBaseRoute: server.apiBaseRoute ?? ""
                )
                return .none

            case .server(let id, .duplicateTapped):
                guard let server = state.allServers[id: id] else { return .none }
                state.editor = EditServerReducer.State(
                    mode: .create,
                    original: ServerConfiguration(scheme: "https", host: "", apiRoute: nil),
                    scheme: server.scheme,
                    host: server.host,
                    apiBaseRoute: server.apiBaseRoute ?? ""
                )
                return .none

            case .server(let id, .deleteTapped):
                state.allServers.remove(id: id)
                serverStore.save(Array(state.allServers))
                endpointStore.delete(id)
                return .none

            case .editor(.presented(.delegate(.didSaveCreate(let server)))):
                state.allServers.append(server)
                serverStore.save(Array(state.allServers))
                state.editor = nil
                let count = coffeeTipClient.incrementSuccessCount()
                if !state.hasTipped && count >= 2 && (count - 2) % 7 == 0 {
                    state.coffeeAlert = AlertState {
                        TextState("Buy me a coffee?")
                    } actions: {
                        ButtonState(role: .cancel) { TextState("Cancel") }
                        ButtonState(action: .confirm) { TextState("Open") }
                    } message: {
                        TextState("Open Buy Me a Coffee in Safari? You'll be taken outside the app.")
                    }
                }
                return .none

            case .editor(.presented(.delegate(.didSaveEdit(let originalId, let server)))):
                if server.id != originalId {
                    endpointStore.migrate(originalId, server.id)
                }
                if let index = state.allServers.index(id: originalId) {
                    state.allServers.remove(at: index)
                    state.allServers.insert(server, at: index)
                }
                serverStore.save(Array(state.allServers))
                state.editor = nil
                return .none

            case .editor(.presented(.delegate(.didCancel))):
                state.editor = nil
                return .none

            case .editor:
                return .none

            case .detail:
                return .none

            case .coffeeTapped:
                state.coffeeAlert = AlertState {
                    TextState("Buy me a coffee?")
                } actions: {
                    ButtonState(role: .cancel) { TextState("Cancel") }
                    ButtonState(action: .confirm) { TextState("Open") }
                } message: {
                    TextState("Open Buy Me a Coffee in Safari? You'll be taken outside the app.")
                }
                return .none

            case .coffeeAlert(.presented(.confirm)):
                coffeeTipClient.markTipped()
                state.hasTipped = true
                return .run { [openURLClient] _ in
                    await openURLClient.open(coffeeURL)
                }

            case .coffeeAlert:
                return .none
            }
        }
        .ifLet(\.$editor, action: \.editor) {
            EditServerReducer()
        }
        .ifLet(\.$detail, action: \.detail) {
            ServerDetailReducer()
        }
        .ifLet(\.$coffeeAlert, action: \.coffeeAlert)
    }
}
