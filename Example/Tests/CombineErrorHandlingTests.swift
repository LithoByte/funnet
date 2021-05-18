////
////  ErrorHandlerTests.swift
////  FunNet_Tests
////
////  Created by Calvin Collins on 5/12/21.
////  Copyright © 2021 CocoaPods. All rights reserved.
////
//
//import Foundation
//import XCTest
//import Combine
//import LithoOperators
//import Prelude
//@testable import FunNet
//
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
