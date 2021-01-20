//
//  MultipartNamingTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 1/20/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import FunNet

class MultipartNamingTests: XCTestCase {
    func testCamelToSnake() {
        let string: String = "userName"
        let converted = camelToSnake(string: string)
        print(converted ?? "nil")
        XCTAssert(converted != nil)
        XCTAssert(converted! == "user_name")
        
        let allLower: String = "name"
        let convertedLower = camelToSnake(string: allLower)
        print(convertedLower ?? "nil")
        XCTAssert(convertedLower != nil)
        XCTAssert(convertedLower! == "name")
        
        let multCaps: String = "QRCode"
        let convertedMultCaps: String? = camelToSnake(string: multCaps)
        print(convertedMultCaps ?? "nil")
        XCTAssert(convertedMultCaps != nil)
        XCTAssert(convertedMultCaps! == "qr_code")
    }
    
    func testCamelFromSnake() {
        let string: String = "user_name"
        let converted = camelFromSnake(string: string)
        print(converted ?? "nil")
        XCTAssert(converted != nil)
        XCTAssert(converted! == "userName")
        
        let allLower: String = "name"
        let convertedLower = camelFromSnake(string: allLower)
        print(convertedLower ?? "nil")
        XCTAssert(convertedLower != nil)
        XCTAssert(convertedLower! == "name")
        
        let multCaps: String = "qr_code"
        let convertedMultCaps: String? = camelFromSnake(string: multCaps)
        print(convertedMultCaps ?? "nil")
        XCTAssert(convertedMultCaps != nil)
        XCTAssert(convertedMultCaps! == "qrCode")
    }
    
    func testNameNesting() {
        // General Test
        let names = ["user", "inviter", "firstName"]
        let nestedNames = makeName(strings: names, index: 1, name: names[0])
        XCTAssert(nestedNames == "user[inviter][firstName]")
        let snakeNestedNames = camelToSnake(string: nestedNames)
        XCTAssert(snakeNestedNames == "user[inviter][first_name]")
        
        //Edge case: Single key
        let singleName = ["user"]
        let nestedSingleName = makeName(strings: singleName, index: 1, name: singleName[0])
        XCTAssert(nestedSingleName == "user")
        XCTAssert(camelToSnake(string: nestedSingleName) == "user")
    }
}
