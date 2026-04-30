import SwiftUI
import ComposableArchitecture

struct ServerDetailView: View {
    let store: StoreOf<ServerDetailReducer>

    var body: some View {
        EndpointListView(store: store.scope(state: \.endpointList, action: \.endpointList))
    }
}
