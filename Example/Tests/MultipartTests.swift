//
//  MultipartTests.swift
//  FunNet_Tests
//
//  Created by Elliot Schrock on 11/18/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
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
}
extension AccountInfo {
    func multipartData() -> MultipartFormData {
        var parts = [MultipartComponent]()
        if let firstName = firstName {
            parts.append(MultipartComponent(data: firstName.data(using: .utf8) ?? Data(), name: "user[first_name]", fileName: nil, contentType:"text"))
        }
        if let lastName = lastName {
            parts.append(MultipartComponent(data: lastName.data(using: .utf8) ?? Data(), name: "user[last_name]", fileName: nil, contentType:"text"))
        }
        if let phoneNumber = phoneNumber {
            parts.append(MultipartComponent(data: phoneNumber.data(using: .utf8) ?? Data(), name: "user[phone_number]", fileName: nil, contentType:"text"))
        }
        if let email = email {
            parts.append(MultipartComponent(data: email.data(using: .utf8) ?? Data(), name: "user[email]", fileName: nil, contentType:"text"))
        }
        if let password = password {
            parts.append(MultipartComponent(data: password.data(using: .utf8) ?? Data(), name: "user[password]", fileName: nil, contentType:"text"))
        }
        if let blob = data {
            parts.append(MultipartComponent(data: blob, name: "user[blob]", fileName: "blob.jpg", contentType:"image/jpeg"))
        }
        return MultipartFormData(parts: parts, boundary: "--boundary-pds-site\(Date().timeIntervalSince1970)file-image-boundary--")
    }
}
