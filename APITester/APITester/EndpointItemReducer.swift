import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct EndpointItemReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: Endpoint.ID { endpoint.id }
        var endpoint: Endpoint
    }
    enum Action: Equatable {
        case tapped
        case duplicateTapped
        case deleteTapped
    }
    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}
