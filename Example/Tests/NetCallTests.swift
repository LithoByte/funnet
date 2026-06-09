//
//  NetCallTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 2/29/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
import FunNet
import ComposableArchitecture

@MainActor
final class NetCallTests: XCTestCase {
    func testDelegate() async throws {
        var endpoint = Endpoint()
        endpoint.method = .post
        endpoint.path = "sessions"
        
        let state = NetCallReducer.State(session: URLSession(configuration: .ephemeral),
                                         baseUrl: URLComponents(string: "https://api.lithobyte.co/api/v1/")!,
                                         endpoint: endpoint,
                                         isInProgress: true,
                                         firingFunc: NetCallReducer.mockFire(with: nil))
        let mainQueue = DispatchQueue.test
        let store = TestStore(initialState: state) {
            NetCallReducer()
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        
        await store.send(.delegate(.responseData(Data()))) {
            $0.isInProgress = false
        }
        
        await store.finish()
    }
    
    func testMockFireNil() async throws {
        var endpoint = Endpoint()
        endpoint.method = .post
        endpoint.path = "sessions"
        
        let state = NetCallReducer.State(session: URLSession(configuration: .ephemeral),
                                         baseUrl: URLComponents(string: "https://api.lithobyte.co/api/v1/")!,
                                         endpoint: endpoint,
                                         firingFunc: NetCallReducer.mockFire(with: nil))
        let mainQueue = DispatchQueue.test
        let store = TestStore(initialState: state) {
            NetCallReducer()
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        
        await store.send(.fire) {
            $0.isInProgress = true
        }
        await mainQueue.advance(by: .seconds(1))
        await store.finish()
    }
    
    func testMockFireData() async throws {
        var endpoint = Endpoint()
        endpoint.method = .post
        endpoint.path = "sessions"
        
        let state = NetCallReducer.State(session: URLSession(configuration: .ephemeral),
                                         baseUrl: URLComponents(string: "https://api.lithobyte.co/api/v1/")!,
                                         endpoint: endpoint,
                                         firingFunc: NetCallReducer.mockFire(with: Data()))
        let mainQueue = DispatchQueue.test
        let store = TestStore(initialState: state) {
            NetCallReducer()
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        
        await store.send(.fire){
            $0.isInProgress = true
        }
        await mainQueue.advance(by: .seconds(1))
        await store.receive(.delegate(.responseData(Data()))) {
            $0.isInProgress = false
        }
        
        await store.finish()
    }
    
    func testMockFireError() async throws {
        var endpoint = Endpoint()
        endpoint.method = .post
        endpoint.path = "sessions"
        
        let error = NSError(domain: "Server", code: 401)
        
        let state = NetCallReducer.State(session: URLSession(configuration: .ephemeral),
                                         baseUrl: URLComponents(string: "https://api.lithobyte.co/api/v1/")!,
                                         endpoint: endpoint,
                                         firingFunc: NetCallReducer.mockFire(with: nil, error: error))
        let mainQueue = DispatchQueue.test
        let store = TestStore(initialState: state) {
            NetCallReducer()
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        
        await store.send(.fire){
            $0.isInProgress = true
        }
        await mainQueue.advance(by: .seconds(1))
        await store.receive(.delegate(.error(error))){
            $0.isInProgress = false
        }
        
        await store.finish()
    }

    func testMockFireHTTPResponse() async throws {
        var endpoint = Endpoint()
        endpoint.method = .get
        endpoint.path = "things"

        let url = URL(string: "https://api.lithobyte.co/api/v1/things")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!

        let state = NetCallReducer.State(session: URLSession(configuration: .ephemeral),
                                         baseUrl: URLComponents(string: "https://api.lithobyte.co/api/v1/")!,
                                         endpoint: endpoint,
                                         firingFunc: NetCallReducer.mockFire(with: Data("{}".utf8),
                                                                             response: httpResponse))
        let mainQueue = DispatchQueue.test
        let store = TestStore(initialState: state) {
            NetCallReducer()
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }

        await store.send(.fire) {
            $0.isInProgress = true
        }
        await mainQueue.advance(by: .seconds(1))
        await store.receive(.delegate(.httpResponse(httpResponse)))
        await store.receive(.delegate(.responseData(Data("{}".utf8)))) {
            $0.isInProgress = false
        }

        await store.finish()
    }
}
