import SwiftUI
import ComposableArchitecture

struct EditServerView: View {
    @Bindable var store: StoreOf<EditServerReducer>

    var body: some View {
        Form {
            TextField("Host", text: $store.host)
        }
    }
}
