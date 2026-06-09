import Foundation

func parsePathField(_ raw: String) -> (path: String, getParams: [URLQueryItem]) {
    let withoutFragment = raw.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)[0]
    let parts = withoutFragment.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)

    var path = String(parts[0])
    if path.hasPrefix("/") { path.removeFirst() }

    let queryString = parts.count == 2 ? String(parts[1]) : ""
    if queryString.isEmpty {
        return (path, [])
    }

    var components = URLComponents()
    components.percentEncodedQuery = queryString
    let items = components.queryItems ?? []

    return (path, items)
}
