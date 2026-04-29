import SwiftUI
import ComposableArchitecture
import FunNetCore

struct EndpointRowView: View {
    @Bindable var store: StoreOf<EndpointItemReducer>

    var body: some View {
        HStack {
            Text(store.endpoint.path).padding()
            Spacer()
        }
    }
}
