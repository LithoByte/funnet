import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        ServerListView(store: Store(initialState: ServerListReducer.State()) {
            ServerListReducer()
        })
    }
}
