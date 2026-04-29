import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct EditServerReducer {
    @ObservableState
    struct State: Equatable {
        var scheme: String = "https"
        var host: String = ""
        var apiBaseRoute: String = ""
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { _, _ in .none }
    }
}
