import SwiftUI
import ComposableArchitecture

struct HeaderEditView: View {
    @Bindable var store: StoreOf<HeaderEditReducer>

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Select") {
                    Button("Content-Type: application/json") {
                        store.send(.quickContentTypeJSONTapped)
                    }
                    Button("Accept: application/json") {
                        store.send(.quickAcceptJSONTapped)
                    }
                    Button("Authorization: Bearer …") {
                        store.send(.quickAuthBearerTapped)
                    }
                }
                Section("Header") {
                    TextField("Key", text: $store.key)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Value", text: $store.value)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                if store.existingKey != nil {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.send(.deleteTapped)
                        }
                    }
                }
            }
            .navigationTitle(store.existingKey == nil ? "New Header" : "Edit Header")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { store.send(.cancelTapped) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { store.send(.saveTapped) }
                        .disabled(store.key.isEmpty)
                }
            }
        }
    }
}
