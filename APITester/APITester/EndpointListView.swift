import SwiftUI
import ComposableArchitecture

struct EndpointListView: View {
    @Bindable var store: StoreOf<EndpointListReducer>

    var body: some View {
        Text("Endpoints")
    }
}
