//
//  ErrorHandlerTests.swift
//  FunNet_Tests
//
//  Created by Calvin Collins on 5/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Combine
import LithoOperators
import Prelude
@testable import FunNet

class NetworkErrHandlerTests: XCTestCase {
    func testConfigs() {
        let handler = NetworkErrHandler(configs: .print, presenter: { _ in })
        XCTAssertTrue(handler.should(.print))
        XCTAssertFalse(handler.should(.debug))
        XCTAssertFalse(handler.should(.production))
    }
    
    func testToStrings() {
        let data = "This is an error".data(using: .utf8)!
        let handler = NetworkErrHandler(configs: .print, .debug, presenter: { _ in })
        XCTAssertEqual(handler.errorDataToString(data), "This is an error")
        let error = NSError(domain: "http://lithobyte.co", code: 300, userInfo: nil)
        XCTAssertEqual(handler.errorToString(error), "Response Error:\n Domain: \(error.domain), Description: \(error.localizedDescription), Code: \(error.code)")
        XCTAssertEqual(handler.serverErrorToString(error), "Server Error:\n Domain: \(error.domain), Description: \(error.localizedDescription), Code: \(error.code)")
    }
}

class SomeOrNilTests: XCTestCase {
    func testConstructor() {
        let stringCount: (String) -> Int = { $0.count }
        let toSomeOrNil = someOrNil(with: stringCount)
        switch toSomeOrNil(nil) {
        case .none:
            break
        case .some(_):
            XCTFail()
        }
        
        switch toSomeOrNil("Hello") {
        case .none:
            XCTFail()
        case .some(let arr):
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual(arr[0], 5)
        }
    }
    
    func testCombine() {
        let stringCount: (String) -> Int = { $0.count }
        let toSomeOrNil = someOrNil(with: stringCount)
        let none = toSomeOrNil(nil)
        let some1 = toSomeOrNil("Hello")
        let some2 = toSomeOrNil("Goodbye")
        
        switch combine(a: some1, b: some2) {
        case .none:
            XCTFail()
        case .some(let arr):
            XCTAssertEqual(arr.count, 2)
        }
        
        switch combine(a: some1, b: none) {
        case .none:
            XCTFail()
        case .some(let arr):
            XCTAssertEqual(arr.count, 1)
        }
        
        switch combine(a: none, b: some1) {
        case .none:
            XCTFail()
        case .some(let arr):
            XCTAssertEqual(arr.count, 1)
        }
        
        switch combine(a: none, b: none) {
        case .none:
            break
        case .some(_):
            XCTFail()
        }
    }
    
    func testReduce() {
        let stringCount: (String) -> Int = { $0.count }
        let toSomeOrNil = someOrNil(with: stringCount)
        let arr1 = ["Hello", "Goodbye", "What's up", "Not much"].map(toSomeOrNil)
        let arr2 = ["Hello", "Goodbye", nil, nil].map(toSomeOrNil)
        let arr3 = [nil, nil, nil, nil].map(toSomeOrNil)
        switch (reduce(arr: arr1)) {
        case .none:
            XCTFail()
        case .some(let arr):
            XCTAssertEqual(arr.count, 4)
        }
        
        switch (reduce(arr: arr2)) {
        case .none:
            XCTFail()
        case .some(let arr):
            XCTAssertEqual(arr.count, 2)
        }
        
        switch reduce(arr: arr3) {
        case .some(_):
            XCTFail()
        case .none:
            break
        }
    }
}

//@available(iOS 13.0, *)
//class CombineErrorHandlingTests: XCTestCase {
//    var cancelBag: Set<AnyCancellable> = []
//    
//    func testPrintingHandlerError() {
//        let errorSub = PassthroughSubject<NSError?, Never>()
//        var wasCalled = false
//        errorSub.sink(receiveValue: (PrintingNetworkErrorHandler().errorFunction() >>> ignoreArg({ })) <> { _ in wasCalled = true }).store(in: &cancelBag)
//        errorSub.send(NSError(domain: "Domain", code: 300, userInfo: nil))
//        XCTAssertTrue(wasCalled)
//    }
//    
//    func testPrintingHandlerData() {
//        let dataSub = PassthroughSubject<Data?, Never>()
//        var wasCalled = false
//        dataSub.sink(receiveValue: (PrintingNetworkErrorHandler().dataFunction() >>> ignoreArg({ })) <> { _ in wasCalled = true }).store(in: &cancelBag)
//        dataSub.send(try! JSONEncoder().encode(ErrorData(title: "Error", message: "Message")))
//        XCTAssertTrue(wasCalled)
//    }
//    
//    func testErrorBinder() {
//        let call = CombineNetCall(configuration: ServerConfiguration(host: "http://fake.com", apiRoute: "api/v1"), Endpoint())
//        call.firingFunc = { call in
//            call.publisher.error = NSError(domain: "Domain", code: 300, userInfo: nil)
//        }
//        combindErrorPrinting(responder: call.publisher, to: PrintingNetworkErrorHandler(), storingIn: &cancelBag)
//        var wasCalled = false
//        call.publisher.$error.sink(receiveValue: { _ in wasCalled = true }).store(in: &cancelBag)
//        call.fire()
//        XCTAssertTrue(wasCalled)
//    }
//    
//    func testDataBinder() {
//        let call = CombineNetCall(configuration: ServerConfiguration(host: "http://fake.com", apiRoute: "api/v1"), Endpoint())
//        call.firingFunc = { call in
//            call.publisher.errorData = try! JSONEncoder().encode(ErrorData(title: "Error", message: "Message"))
//        }
//        combindDataPrinting(responder: call.publisher, to: PrintingNetworkErrorHandler(), storingIn: &cancelBag)
//        var wasCalled = false
//        call.publisher.$errorData.sink(receiveValue: { _ in wasCalled = true }).store(in: &cancelBag)
//        call.fire()
//        XCTAssertTrue(wasCalled)
//        let funnet = FunNetCall(configuration: ServerConfiguration(host: "http://fake.com", apiRoute: "api/v1"), Endpoint(), responder: NetworkResponder())
//        funnet.firingFunc = { call in
//            call.responder?.
//        }
//    }
//}
//
//private struct ErrorData: Codable {
//    var title: String?
//    var message: String?
//}
