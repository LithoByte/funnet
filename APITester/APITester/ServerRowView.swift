import SwiftUI
import ComposableArchitecture
import FunNetCore

struct ServerRowView: View {
    let store: StoreOf<ServerItemReducer>

    var body: some View {
        HStack {
            Text(store.server.host).padding()
            Spacer()
        }
    }
}
