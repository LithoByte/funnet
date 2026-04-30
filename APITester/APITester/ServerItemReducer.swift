import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct ServerItemReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: ServerConfiguration.ID { server.id }
        var server: ServerConfiguration
    }
    enum Action: Equatable {
        case tapped
        case duplicateTapped
        case editTapped
        case deleteTapped
    }
    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}
