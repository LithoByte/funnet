//
//  MultipartHelperFunctions.swift
//  FunNet
//
//  Created by Elliot Schrock on 1/22/21.
//

import Foundation

#if canImport(Core)
    import Core
#endif

public func addMultipartHeaders(_ endpoint: inout Endpoint, from multipartData: MultipartFormData) {
    endpoint.addHeaders(headers: [
        "Content-Type": "multipart/form-data; charset=utf-8; boundary=\"\(multipartData.boundary)\"",
        "Content-Length": "\(multipartData.countContentLength())",
        "Accept": "application/json"
    ])
}

public extension Endpoint {
    mutating func addModelStream<E: Encodable>(model: E, encoder: FormDataEncoder = FormDataEncoder()) {
        guard let formData = try? encoder.encode(model) else { return }
        self.dataStream = formData.makeInputStream()
    }
}
