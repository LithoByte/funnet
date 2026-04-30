import SwiftUI
import ComposableArchitecture

struct EditServerView: View {
    @Bindable var store: StoreOf<EditServerReducer>

    var body: some View {
        NavigationStack {
            Form {
                Picker("Scheme", selection: $store.scheme) {
                    Text("https").tag("https")
                    Text("http").tag("http")
                }
                .pickerStyle(.segmented)

                TextField("Host (e.g. api.example.com)", text: $store.host)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                TextField("Base path (optional, e.g. v1)", text: $store.apiBaseRoute)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { store.send(.cancelTapped) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { store.send(.saveTapped) }
                        .disabled(!store.canSave)
                }
            }
        }
    }

    private var title: String {
        switch store.mode {
        case .create: return "New Server"
        case .edit:   return "Edit Server"
        }
    }
}
