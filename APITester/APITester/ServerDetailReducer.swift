import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct ServerDetailReducer {
    @ObservableState
    struct State {
        var server: ServerConfiguration
    }
    enum Action: Equatable {}
    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}
