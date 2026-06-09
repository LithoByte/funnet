import Foundation
import ComposableArchitecture
import FunNetCore

@Reducer
struct ServerDetailReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: ServerConfiguration.ID { server.id }
        var server: ServerConfiguration
        var endpointList: EndpointListReducer.State

        init(server: ServerConfiguration) {
            self.server = server
            self.endpointList = EndpointListReducer.State(server: server)
        }
    }
    enum Action: Equatable {
        case endpointList(EndpointListReducer.Action)
    }
    var body: some Reducer<State, Action> {
        Scope(state: \.endpointList, action: \.endpointList) {
            EndpointListReducer()
        }
        Reduce { _, _ in .none }
    }
}
