import SwiftUI
import ComposableArchitecture
import FunNetCore

struct EditEndpointView: View {
    @Bindable var store: StoreOf<EditEndpointReducer>

    private let methods: [HttpMethod] = [.get, .put, .patch, .post, .delete]

    private var bodyText: Binding<String> {
        Binding(
            get: { store.endpoint.postData.flatMap { String(data: $0, encoding: .utf8) } ?? "" },
            set: { store.send(.bodyChanged($0)) }
        )
    }

    private var methodSelection: Binding<HttpMethod> {
        Binding(
            get: { store.endpoint.method },
            set: { store.send(.methodPicked($0)) }
        )
    }

    var body: some View {
        Form {
            Section("Method") {
                Picker("Method", selection: methodSelection) {
                    ForEach(methods, id: \.rawValue) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Path") {
                TextField("path?query=…", text: $store.pathField)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            Section("Headers") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button {
                            store.send(.addHeaderTapped)
                        } label: {
                            Image(systemName: "plus").padding(.horizontal, 8).padding(.vertical, 4)
                        }
                        .buttonStyle(.bordered)

                        ForEach(Array(store.endpoint.httpHeaders.keys.sorted()), id: \.self) { key in
                            Button {
                                store.send(.headerCapsuleTapped(key: key))
                            } label: {
                                Text(key).lineLimit(1)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

            Section("Body") {
                BodyEditor(text: bodyText)
                    .frame(minHeight: 160)
            }

            Section {
                Button("Fire") {
                    store.send(.fireTapped)
                }
                .frame(maxWidth: .infinity)
                .disabled(store.pathField.isEmpty)
            }
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
        .sheet(item: $store.scope(state: \.headerEdit, action: \.headerEdit)) { editStore in
            HeaderEditView(store: editStore)
        }
        .sheet(item: $store.scope(state: \.response, action: \.response)) { responseStore in
            ResponseView(store: responseStore)
        }
    }

    private var title: String {
        switch store.mode {
        case .create:    return "New Endpoint"
        case .edit:      return "Edit Endpoint"
        case .duplicate: return "Duplicate Endpoint"
        }
    }
}
