import SwiftUI
import ComposableArchitecture
import FunNetCore

struct ServerListView: View {
    @Environment(\.scenePhase) var scenePhase
    @Bindable var store: StoreOf<ServerListReducer>

    var body: some View {
        NavigationStack {
            List {
                if store.allServers.isEmpty {
                    Text("No servers yet — tap +").foregroundColor(.secondary)
                } else {
                    ForEach(store.displayedServers) { server in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(server.host).font(.body)
                                Text("\(server.scheme)://\(server.host)/\(server.apiBaseRoute ?? "")")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                store.send(.server(server.id, .duplicateTapped))
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { store.send(.server(server.id, .tapped)) }
                        .swipeActions {
                            Button(role: .destructive) {
                                store.send(.server(server.id, .deleteTapped))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                store.send(.server(server.id, .editTapped))
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { store.send(.addNewTapped) } label: { Image(systemName: "plus") }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if CoffeeTipClient.isEnabled && !store.hasTipped {
                    Button {
                        store.send(.coffeeTapped)
                    } label: {
                        Text("I hate ads and paywalls, so this app is free. Please tip if it's helpful by clicking here!")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .alert($store.scope(state: \.coffeeAlert, action: \.coffeeAlert))
            .navigationDestination(item: $store.scope(state: \.detail, action: \.detail)) { detailStore in
                ServerDetailView(store: detailStore)
            }
            .sheet(item: $store.scope(state: \.editor, action: \.editor)) { editorStore in
                EditServerView(store: editorStore)
            }
            .searchable(text: $store.localFilter)
            .onAppear { store.send(.didChangeScenePhase) }
            .onChange(of: scenePhase) { _, _ in store.send(.didChangeScenePhase) }
        }
    }
}
