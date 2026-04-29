import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct ServerListReducer {
    @ObservableState
    struct State {
        var allServers: [ServerConfiguration] = []
        var localFilter: String = ""
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addNewTapped
        case didChangeScenePhase
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { _, _ in .none }
    }
}
