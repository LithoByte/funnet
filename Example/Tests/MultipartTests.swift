//
//  MultipartTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 11/18/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import LithoOperators
@testable import FunNet


class MultipartTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testMultipartComponent() throws {
        let formData = try FormDataEncoder().encode(["greeting": "hello"], boundary: "--boundary-\(Date().timeIntervalSince1970)file-image-boundary--")
        let stream = formData.makeInputStream()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: formData.countContentLength())
        stream.read(buffer, maxLength: formData.countContentLength())
        print(String(cString: buffer))
        
    }
    
    func testMultipartFormDataEncoder() throws {
        let encoder = FormDataEncoder()
        let userInfo = AccountInfo(firstName: "Calvin", lastName: "Collins", phoneNumber: "1234", email: "cjc8@williams.edu", password: "password", passwordConfirmation: "password", invitationToken: "token", data: Data(base64Encoded: "abcd"))
        let holder = AccountInfoHolder(accountInfo: userInfo)
        let boundary = "--boundary-\(Date().timeIntervalSince1970)file-image-boundary--"
        guard let multipartForm: MultipartFormData = try? encoder.encode(holder, boundary: boundary) else {
            return XCTAssert(false)
        }
        let stream = multipartForm.makeInputStream()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: multipartForm.countContentLength())
        stream.read(buffer, maxLength: multipartForm.countContentLength())
        let encodedString = String(cString: buffer)
        let parts: [String] = encodedString.components(separatedBy: boundary)
        XCTAssert(parts.filter({ $0.contains("account_info[first_name]") }).count != 0)
        XCTAssert(parts.filter({ $0.contains("account_info[last_name]") }).count != 0)
    }
    
    func testArrayMultipartEncoder() {
        let encoder = FormDataEncoder()
        let userInfo1 = AccountInfo(firstName: "Calvin", lastName: "Collins", phoneNumber: "1234", email: "cjc8@williams.edu", password: "password", passwordConfirmation: "password", invitationToken: "token", data: Data(base64Encoded: "abcd"))
        let userInfo2 = AccountInfo(firstName: "Elliot", lastName: "Schrock", phoneNumber: "1234", email: "elliot@williams.edu", password: "password", passwordConfirmation: "password", invitationToken: "token", data: Data(base64Encoded: "abcd"))
        let holder1 = AccountInfoHolder(accountInfo: userInfo1)
        let holder2 = AccountInfoHolder(accountInfo: userInfo2)
        let holderHolder = AccountInfoHolderHolder(holders: [holder1, holder2])
        let boundary = "--boundary-\(Date().timeIntervalSince1970)file-image-boundary--"
        guard let multipartForm: MultipartFormData = try? encoder.encode(holderHolder, boundary: boundary) else {
            return XCTAssert(false)
        }
        let stream = multipartForm.makeInputStream()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: multipartForm.countContentLength())
        stream.read(buffer, maxLength: multipartForm.countContentLength())
        let encodedString = String(cString: buffer)
        let parts: [String] = encodedString.components(separatedBy: boundary)
        XCTAssert(parts.filter({ $0.contains("holders[][account_info][first_name]") }).count == 2)
    }
    
    func testArrayConvertibleEncoder() {
        let encoder = FormDataEncoder()
        let image = UIImage(named: "0.jpg")?.jpgImage()
        let boundary = "--boundary-\(Date().timeIntervalSince1970)file-image-boundary--"
        guard let multipartForm: MultipartFormData = try? encoder.encode([image], boundary: boundary) else {
            return XCTAssert(false)
        }
        let stream = multipartForm.makeInputStream()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: multipartForm.countContentLength())
        stream.read(buffer, maxLength: multipartForm.countContentLength())
        let encodedString = String(cString: buffer)
        print(encodedString)
        let parts: [String] = encodedString.components(separatedBy: boundary)
        XCTAssert(parts.filter({ $0.contains("name=\"0\"") }).count == 1)
    }
}

public struct AccountInfoHolderHolder: Codable {
    var holders: [AccountInfoHolder]
}


public struct AccountInfoHolder: Codable {
    var accountInfo: AccountInfo?
}

public struct AccountInfo: Codable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var email: String?
    var password: String?
    var passwordConfirmation: String?
    var invitationToken: String?
    var data: Data?
    var avatar: JpgImage?
}
