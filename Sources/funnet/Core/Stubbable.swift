//
//  Stubbable.swift
//  FunkyNetwork
//
//  Created by Elliot Schrock on 1/24/19.
//

import UIKit

public protocol Stubbable {
    var stubHolder: StubHolderProtocol? { get }
    var stubCondition: (URLRequest) -> Bool { mutating get }
}

public func defaultStubCondition(configuration: ServerConfigurationProtocol,
                                 endpoint: EndpointProtocol) -> ((URLRequest) -> Bool) {
        return {
            let urlString = configuration.toBaseUrlString() + endpoint.path
            return $0.url?.absoluteString == urlString && $0.httpMethod == endpoint.httpMethod
        }
}

//public extension StubHolderProtocol {
//    func stubResponseBlock() -> OHHTTPStubsResponseBlock {
//        return { _ in
//            if let fileName = self.stubFileName {
//                if let stubPath = OHPathForFileInBundle(fileName, self.bundle) {
//                    return fixture(filePath: stubPath, status: self.responseCode, headers: self.responseHeaders)
//                } else {
//                    print("Could not find path for file: \(fileName); is it in the right bundle?")
//                }
//            } else if let stubData = self.stubData {
//                return OHHTTPStubsResponse(data: stubData, statusCode: self.responseCode, headers: self.responseHeaders)
//            }
//            return OHHTTPStubsResponse(data: Data(), statusCode: self.responseCode, headers: self.responseHeaders)
//        }
//    }
//}
