import SwiftUI
import ComposableArchitecture
import FunNetCore

struct ServerDetailView: View {
    let store: StoreOf<ServerDetailReducer>

    var body: some View {
        Text(store.server.host)
    }
}
