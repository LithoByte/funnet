//
//  MultipartFormData.swift
//  PDSLibrary
//
//  Created by Soroush Khanlou on 9/26/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation

public class MultipartFormData {

    public let parts: [MultipartComponent]
    public let boundary: String

    public init(parts: [MultipartComponent], boundary: String) {
        self.parts = parts
        self.boundary = boundary
    }

    public func makeInputStream() -> InputStream {
        let streams = self.parts.map({ $0.inputStream(usingBoundary: self.makeHyphenatedBoundary()) }) + [InputStream(data: self.makeFinalBoundary())]
        return SerialInputStream(inputStreams: streams)
    }

    public func countContentLength() -> Int {
        return self.parts
            .map({ $0.contentLength(usingBoundary: self.makeHyphenatedBoundary()) })
            .reduce(0, +)
            + self.makeFinalBoundary().count
    }

    private func makeHyphenatedBoundary() -> String {
        return "--" + self.boundary
    }

    private func makeFinalBoundary() -> Data {
        return "--\(self.boundary)--\r\n".data(using: .utf8)!
    }
}

