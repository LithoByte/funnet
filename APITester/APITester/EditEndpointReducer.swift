import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct EditEndpointReducer {
    @ObservableState
    struct State: Equatable {
        var endpoint: Endpoint = Endpoint()
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { _, _ in .none }
    }
}
