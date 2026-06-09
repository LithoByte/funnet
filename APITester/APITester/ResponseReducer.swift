import Foundation
import ComposableArchitecture

func prettyPrintJSON(_ data: Data) -> String? {
    guard let obj = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]),
          let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys])
    else { return nil }
    return String(data: pretty, encoding: .utf8)
}

func renderBody(_ data: Data?) -> String {
    guard let data, !data.isEmpty else { return "" }
    if let pretty = prettyPrintJSON(data) { return pretty }
    if let str = String(data: data, encoding: .utf8) { return str }
    return "<\(data.count) bytes>"
}

@Reducer
struct ResponseReducer {
    struct HeaderRow: Equatable, Identifiable {
        var id: String { key }
        var key: String
        var value: String
    }

    @ObservableState
    struct State: Equatable {
        var statusCode: Int?
        var headers: [HeaderRow] = []
        var body: Data?
        var error: NSError?
    }

    enum Action: Equatable {
        case dismiss
    }

    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}

extension ResponseReducer.State {
    static func from(httpResponse: HTTPURLResponse) -> Self {
        let rows = (httpResponse.allHeaderFields as? [String: String] ?? [:])
            .map { ResponseReducer.HeaderRow(key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
        return Self(statusCode: httpResponse.statusCode, headers: rows, body: nil, error: nil)
    }
}
