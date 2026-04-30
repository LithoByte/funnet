import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct EditServerReducer {
    enum Mode: Equatable {
        case create
        case edit(originalId: ServerConfiguration.ID)
    }

    @ObservableState
    struct State: Equatable {
        var mode: Mode
        var original: ServerConfiguration
        var scheme: String
        var host: String
        var apiBaseRoute: String

        var build: ServerConfiguration {
            ServerConfiguration(scheme: scheme,
                                host: host,
                                apiRoute: apiBaseRoute.isEmpty ? nil : apiBaseRoute)
        }
        var canSave: Bool { build != original && !host.isEmpty }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case saveTapped
        case cancelTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case didSaveCreate(ServerConfiguration)
            case didSaveEdit(originalId: ServerConfiguration.ID, ServerConfiguration)
            case didCancel
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .saveTapped:
                guard state.canSave else { return .none }
                let server = state.build
                switch state.mode {
                case .create:
                    return .send(.delegate(.didSaveCreate(server)))
                case .edit(let originalId):
                    return .send(.delegate(.didSaveEdit(originalId: originalId, server)))
                }
            case .cancelTapped:
                return .send(.delegate(.didCancel))
            case .delegate:
                return .none
            }
        }
    }
}
