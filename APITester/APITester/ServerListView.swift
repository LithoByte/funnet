import SwiftUI
import ComposableArchitecture

struct ServerListView: View {
    @Bindable var store: StoreOf<ServerListReducer>

    var body: some View {
        NavigationStack {
            Text("Servers")
                .navigationTitle("Servers")
        }
    }
}
