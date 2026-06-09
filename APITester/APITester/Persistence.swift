import Foundation
import ComposableArchitecture
import FunNetCore

struct PersistedServerConfiguration: Codable {
    var shouldStub: Bool
    var shouldUseCookies: Bool
    var scheme: String
    var host: String
    var apiBaseRoute: String?

    init(_ s: ServerConfiguration) {
        shouldStub = s.shouldStub
        shouldUseCookies = s.shouldUseCookies
        scheme = s.scheme
        host = s.host
        apiBaseRoute = s.apiBaseRoute
    }

    func toServerConfiguration() -> ServerConfiguration {
        ServerConfiguration(shouldStub: shouldStub,
                            shouldUseCookies: shouldUseCookies,
                            scheme: scheme,
                            host: host,
                            apiRoute: apiBaseRoute)
    }
}

struct ServerStore {
    var load: () -> [ServerConfiguration]
    var save: ([ServerConfiguration]) -> Void
}

struct EndpointStore {
    var load: (_ serverID: ServerConfiguration.ID) -> [Endpoint]
    var save: (_ endpoints: [Endpoint], _ serverID: ServerConfiguration.ID) -> Void
    var migrate: (_ from: ServerConfiguration.ID, _ to: ServerConfiguration.ID) -> Void
    var delete: (_ serverID: ServerConfiguration.ID) -> Void
}

private let serversKey = "funnet.servers"
private func endpointsKey(_ serverID: ServerConfiguration.ID) -> String {
    "funnet.endpoints.\(serverID)"
}

func makeServerStore(defaults: UserDefaults) -> ServerStore {
    ServerStore(
        load: {
            guard let data = defaults.data(forKey: serversKey),
                  let persisted = try? JSONDecoder().decode([PersistedServerConfiguration].self, from: data)
            else { return [] }
            return persisted.map { $0.toServerConfiguration() }
        },
        save: { servers in
            let persisted = servers.map(PersistedServerConfiguration.init)
            if let data = try? JSONEncoder().encode(persisted) {
                defaults.set(data, forKey: serversKey)
            }
        }
    )
}

func makeEndpointStore(defaults: UserDefaults) -> EndpointStore {
    EndpointStore(
        load: { serverID in
            guard let data = defaults.data(forKey: endpointsKey(serverID)),
                  let endpoints = try? JSONDecoder().decode([Endpoint].self, from: data)
            else { return [] }
            return endpoints
        },
        save: { endpoints, serverID in
            if let data = try? JSONEncoder().encode(endpoints) {
                defaults.set(data, forKey: endpointsKey(serverID))
            }
        },
        migrate: { from, to in
            if let data = defaults.data(forKey: endpointsKey(from)) {
                defaults.set(data, forKey: endpointsKey(to))
                defaults.removeObject(forKey: endpointsKey(from))
            }
        },
        delete: { serverID in
            defaults.removeObject(forKey: endpointsKey(serverID))
        }
    )
}

private enum ServerStoreKey: DependencyKey {
    static let liveValue = makeServerStore(defaults: .standard)
    static let testValue = ServerStore(load: { [] }, save: { _ in })
}

private enum EndpointStoreKey: DependencyKey {
    static let liveValue = makeEndpointStore(defaults: .standard)
    static let testValue = EndpointStore(load: { _ in [] },
                                         save: { _, _ in },
                                         migrate: { _, _ in },
                                         delete: { _ in })
}

extension DependencyValues {
    var serverStore: ServerStore {
        get { self[ServerStoreKey.self] }
        set { self[ServerStoreKey.self] = newValue }
    }
    var endpointStore: EndpointStore {
        get { self[EndpointStoreKey.self] }
        set { self[EndpointStoreKey.self] = newValue }
    }
}
