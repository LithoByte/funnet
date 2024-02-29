//
//  NetCallReducer.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/29/24.
//

import Foundation
#if canImport(FunNetTCA)
import FunNetCore
#endif
import ComposableArchitecture

public struct NetCaller: Equatable {
    public var session: URLSession = URLSession(configuration: .default)
    public var baseUrl: URLComponents
    public var endpoint: Endpoint
    public var logLevel: FunNetRequestLogLevel = .none
}

public struct PagingMeta {
    public var pageKey: String = "page"
    public var pageCountKey: String = "count"
    public var firstPage: Int = 1
    public var perPage: Int = 20
}

@Reducer
public struct NetCallReducer {
    @Dependency(\.mainQueue) public static var mainQueue
    
    @ObservableState
    public struct State: Equatable {
        public static func == (lhs: NetCallReducer.State, rhs: NetCallReducer.State) -> Bool {
            return lhs.toNetCaller() == rhs.toNetCaller() && lhs.isInProgress == rhs.isInProgress
        }
        
        public var session: URLSession
        public var baseUrl: URLComponents
        public var endpoint: Endpoint
        public var logLevel: FunNetRequestLogLevel = .none
        
        public var isInProgress: Bool = false
        
        public var pagingInfo: PagingMeta?
        
        public var reset: ((inout Endpoint) -> Void)?
        public var firingFunc: (NetCaller) -> @Sendable (Send<NetCallReducer.Action>) async throws -> Void = NetCallReducer.fireFunction(_:)
        
        public init(session: URLSession, baseUrl: URLComponents, endpoint: Endpoint, logLevel: FunNetRequestLogLevel = .none, isInProgress: Bool = false, pagingInfo: PagingMeta? = nil, reset: ((inout Endpoint) -> Void)? = nil, firingFunc: @escaping (NetCaller) -> @Sendable (Send<NetCallReducer.Action>) async throws -> Void = NetCallReducer.fireFunction(_:)) {
            self.session = session
            self.baseUrl = baseUrl
            self.endpoint = endpoint
            self.logLevel = logLevel
            self.isInProgress = isInProgress
            self.pagingInfo = pagingInfo
            self.reset = reset
            self.firingFunc = firingFunc
        }
        
        public func toNetCaller() -> NetCaller {
            return NetCaller(session: session, baseUrl: baseUrl, endpoint: endpoint, logLevel: logLevel)
        }
    }
    
    public enum Action: Sendable, Equatable {
        case fire
        case refresh
        case nextPage
        
        case delegate(Delegate)
        
        public enum Delegate: Sendable, Equatable {
            public static func == (lhs: NetCallReducer.Action.Delegate, rhs: NetCallReducer.Action.Delegate) -> Bool {
                switch lhs {
                case .responseData(let ldata):
                    switch rhs {
                    case .responseData(let rdata):
                        return ldata == rdata
                    case .error(_):
                        return false
                    }
                case .error(let lerror):
                    switch rhs {
                    case .responseData(_):
                        return false
                    case .error(let rerror):
                        return lerror.localizedDescription == rerror.localizedDescription
                    }
                }
            }
            
            case responseData(Data)
            case error(Error)
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fire:
                state.isInProgress = true
                return .run(operation: state.firingFunc(state.toNetCaller()))
            case .refresh:
                if let reset = state.reset {
                    reset(&state.endpoint)
                } else if let pagingInfo = state.pagingInfo {
                    let reset = defaultResetEndpoint(pageKey: pagingInfo.pageKey, perPage: pagingInfo.perPage, countKey: pagingInfo.pageCountKey, firstPage: pagingInfo.firstPage)
                    reset(&state.endpoint)
                }
                state.isInProgress = true
                return .run(operation: state.firingFunc(state.toNetCaller()))
            case .nextPage:
                if let pagingInfo = state.pagingInfo {
                    state.endpoint.incrementPageParams(pageKey: pagingInfo.pageKey, perPage: pagingInfo.perPage, countKey: pagingInfo.pageCountKey, firstPage: pagingInfo.firstPage)
                }
                state.isInProgress = true
                return .run(operation: state.firingFunc(state.toNetCaller()))
            case .delegate(_):
                state.isInProgress = false
                return .none
            }
        }
    }
}

public extension NetCallReducer {
    static func fireFunction(_ call: NetCaller)
    -> @Sendable (Send<NetCallReducer.Action>) async throws -> Void {
        return { send in
            if let request = generateRequest(from: call.baseUrl, endpoint: call.endpoint, logLevel: call.logLevel) {
                do {
                    let (data, response) = try await call.session.data(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode > 299 {
                            var info: [String: Any] = ["url" : httpResponse.url?.absoluteString as Any]
                            
                            if let stringData = String(data: data, encoding: .utf8) {
                                info["data"] = stringData
                            }
                            
                            await send(.delegate(.error(NSError(domain: "Server", code: httpResponse.statusCode, userInfo: info))))
                        }
                    }
                    
                    await send(.delegate(.responseData(data)))
                } catch let error {
                    await send(.delegate(.error(error)))
                }
            }
        }
    }
    
    static func mockFire(with data: Data?,
                         response: URLResponse? = nil,
                         error: Error? = nil,
                         delayMillis: Int? = 1000)
    -> (NetCaller) -> @Sendable (Send<NetCallReducer.Action>) async throws -> Void {
        return { call in
            return { send in
                if let _ = generateRequest(from: call.baseUrl, endpoint: call.endpoint, logLevel: call.logLevel) {
                    if let delayMillis {
                        try await Self.mainQueue.sleep(for: .milliseconds(delayMillis))
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode > 299 {
                            var info: [String: Any] = ["url" : httpResponse.url?.absoluteString as Any]
                            
                            if let data, let stringData = String(data: data, encoding: .utf8) {
                                info["data"] = stringData
                            }
                            
                            await send(.delegate(.error(NSError(domain: "Server", code: httpResponse.statusCode, userInfo: info))))
                        }
                    }
                    
                    if let error {
                        await send(.delegate(.error(error)))
                    }
                    
                    if let data {
                        await send(.delegate(.responseData(data)))
                    }
                } else if let error {
                    await send(.delegate(.error(error)))
                }
            }
        }
    }
}
