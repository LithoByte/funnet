import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct EndpointItemReducer {
    @ObservableState
    struct State: Equatable {
        var endpoint: Endpoint
    }
    enum Action: Equatable {}
    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}
