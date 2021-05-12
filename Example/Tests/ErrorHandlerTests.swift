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
@testable import FunNet

@available(iOS 13.0, *)
class ErrorHandlerTests: XCTestCase {
    var cancelBag: Set<AnyCancellable> = []
    
    func testPrintingHandlerError() {
        let errorSub = PassthroughSubject<NSError?, Never>()
        var wasCalled = false
        errorSub.sink(receiveValue: PrintingNetworkErrorHandler().errorFunction() <> { _ in wasCalled = true }).store(in: &cancelBag)
        errorSub.send(NSError(domain: "Domain", code: 300, userInfo: nil))
        XCTAssertTrue(wasCalled)
    }
    
    func testPrintingHandlerData() {
        let dataSub = PassthroughSubject<Data?, Never>()
        var wasCalled = false
        dataSub.sink(receiveValue: PrintingNetworkErrorHandler().dataFunction() <> { _ in wasCalled = true }).store(in: &cancelBag)
        dataSub.send(try! JSONEncoder().encode(ErrorData(title: "Error", message: "Message")))
        XCTAssertTrue(wasCalled)
    }
}

struct ErrorData: Codable {
    var title: String?
    var message: String?
}
