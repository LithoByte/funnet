import Foundation
import FunNetCore

private struct CodableQueryItem: Codable {
    var name: String
    var value: String?

    init(_ item: URLQueryItem) {
        name = item.name
        value = item.value
    }

    var queryItem: URLQueryItem { URLQueryItem(name: name, value: value) }
}

extension Endpoint: Codable {
    enum CodingKeys: String, CodingKey {
        case httpMethod, httpHeaders, path, getParams, timeout, postData
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        httpMethod  = try c.decode(String.self,                forKey: .httpMethod)
        httpHeaders = try c.decode([String: String].self,      forKey: .httpHeaders)
        path        = try c.decode(String.self,                forKey: .path)
        getParams   = try c.decode([CodableQueryItem].self,    forKey: .getParams).map(\.queryItem)
        timeout     = try c.decode(TimeInterval.self,          forKey: .timeout)
        postData    = try c.decodeIfPresent(Data.self,         forKey: .postData)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(httpMethod,                              forKey: .httpMethod)
        try c.encode(httpHeaders,                             forKey: .httpHeaders)
        try c.encode(path,                                    forKey: .path)
        try c.encode(getParams.map(CodableQueryItem.init),    forKey: .getParams)
        try c.encode(timeout,                                 forKey: .timeout)
        try c.encodeIfPresent(postData,                       forKey: .postData)
    }
}

extension Endpoint: Identifiable {
    public var id: Int {
        var h = Hasher()
        h.combine(path)
        h.combine(httpMethod)
        h.combine(httpHeaders)
        h.combine(postData)
        return h.finalize()
    }
}
