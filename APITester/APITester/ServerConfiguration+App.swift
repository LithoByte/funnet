import Foundation
import FunNetCore

extension ServerConfiguration: Identifiable {
    public var id: Int {
        var h = Hasher()
        h.combine(scheme)
        h.combine(host)
        h.combine(apiBaseRoute)
        return h.finalize()
    }
}

extension ServerConfiguration: Equatable {
    public static func == (lhs: ServerConfiguration, rhs: ServerConfiguration) -> Bool {
        lhs.scheme == rhs.scheme
            && lhs.host == rhs.host
            && lhs.apiBaseRoute == rhs.apiBaseRoute
            && lhs.shouldStub == rhs.shouldStub
            && lhs.shouldUseCookies == rhs.shouldUseCookies
    }
}

extension ServerConfiguration {
    func copy() -> ServerConfiguration {
        ServerConfiguration(
            shouldStub: shouldStub,
            shouldUseCookies: shouldUseCookies,
            scheme: scheme,
            host: host,
            apiRoute: apiBaseRoute,
            urlConfiguration: urlConfiguration
        )
    }
}
