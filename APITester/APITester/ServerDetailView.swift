import SwiftUI
import ComposableArchitecture
import FunNetCore

struct ServerDetailView: View {
    @Bindable var store: StoreOf<ServerDetailReducer>

    var body: some View {
        Text(store.server.host)
    }
}
