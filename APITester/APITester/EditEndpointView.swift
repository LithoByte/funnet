import SwiftUI
import ComposableArchitecture
import FunNetCore

struct EditEndpointView: View {
    @Bindable var store: StoreOf<EditEndpointReducer>

    var body: some View {
        Form {
            TextField("Path", text: $store.endpoint.path)
        }
    }
}
