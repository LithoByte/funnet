import SwiftUI
import ComposableArchitecture
import FunNetCore

struct EndpointListView: View {
    @Environment(\.scenePhase) var scenePhase
    @Bindable var store: StoreOf<EndpointListReducer>

    var body: some View {
        List {
            if store.allEndpoints.isEmpty {
                Text("No endpoints yet — tap +").foregroundColor(.secondary)
            } else {
                ForEach(store.displayedEndpoints) { endpoint in
                    HStack {
                        Text(endpoint.httpMethod).font(.caption.bold()).frame(width: 56, alignment: .leading)
                        Text(endpoint.path).lineLimit(1)
                        Spacer()
                        Button {
                            store.send(.endpoint(endpoint.id, .duplicateTapped))
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.borderless)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { store.send(.endpoint(endpoint.id, .tapped)) }
                    .swipeActions {
                        Button(role: .destructive) {
                            store.send(.endpoint(endpoint.id, .deleteTapped))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(store.server.host)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { store.send(.addNewTapped) } label: { Image(systemName: "plus") }
            }
        }
        .navigationDestination(item: $store.scope(state: \.editor, action: \.editor)) { editStore in
            EditEndpointView(store: editStore)
        }
        .searchable(text: $store.localFilter)
        .onAppear { store.send(.didChangeScenePhase) }
        .onChange(of: scenePhase) { _, _ in store.send(.didChangeScenePhase) }
    }
}
