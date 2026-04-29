import SwiftUI
import ComposableArchitecture

struct ResponseView: View {
    @Bindable var store: StoreOf<ResponseReducer>

    var statusColor: Color {
        guard let code = store.statusCode else { return .secondary }
        switch code {
        case ..<300: return .green
        case ..<400: return .orange
        default:     return .red
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let code = store.statusCode {
                        Text("\(code)").font(.largeTitle.bold()).foregroundColor(statusColor)
                    } else if store.error != nil {
                        Text("No HTTP response").font(.title3).foregroundColor(.red)
                    }

                    if !store.headers.isEmpty {
                        Section {
                            ForEach(store.headers) { row in
                                VStack(alignment: .leading) {
                                    Text(row.key).font(.caption).foregroundColor(.secondary)
                                    Text(row.value).font(.callout)
                                }
                            }
                        } header: {
                            Text("Headers").font(.headline)
                        }
                    }

                    Section {
                        Text(renderBody(store.body))
                            .font(.system(.callout, design: .monospaced))
                            .textSelection(.enabled)
                    } header: {
                        Text("Body").font(.headline)
                    }

                    if let error = store.error {
                        Section {
                            Text(error.localizedDescription).foregroundColor(.red)
                        } header: {
                            Text("Error").font(.headline)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Response")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { store.send(.dismiss) }
                }
            }
        }
    }
}
