import SwiftUI
import ComposableArchitecture
import FunNetCore

struct ServerRowView: View {
    @Bindable var store: StoreOf<ServerItemReducer>

    var body: some View {
        HStack {
            Text(store.server.host).padding()
            Spacer()
        }
    }
}
