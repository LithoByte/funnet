import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct EndpointListReducer {
    @ObservableState
    struct State: Equatable {
        var allEndpoints: [Endpoint] = []
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
