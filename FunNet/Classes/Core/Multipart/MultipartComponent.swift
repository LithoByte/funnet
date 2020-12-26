//
//  MultipartComponent.swift
//  PDSLibrary
//
//  Created by Soroush Khanlou on 9/26/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation

public final class MultipartComponent {
    public let dataStream: InputStream
    public let name: String
    public let fileName: String?
    public let contentType: String
    public let streamLength: Int
    
    public init(dataStream: InputStream, name: String, fileName: String?, contentType: String, streamLength: Int) {
        self.dataStream = dataStream
        self.name = name
        self.fileName = fileName
        self.contentType = contentType
        self.streamLength = streamLength
    }

    public func inputStream(usingBoundary boundary: String) -> InputStream {
        let streams = [
            InputStream(data: self.prefixData(usingBoundary: boundary)),
            self.dataStream,
            InputStream(data: self.postfixData(usingBoundary: boundary)),
        ]

        return SerialInputStream(inputStreams: streams)
    }

    public func contentLength(usingBoundary boundary: String) -> Int {
        return self.prefixData(usingBoundary: boundary).count
            + self.streamLength
            + self.postfixData(usingBoundary: boundary).count
    }

    public func prefixData(usingBoundary boundary: String) -> Data {

        var fileNameComponent: String {
            if let fileName = self.fileName {
                return "; filename=\"\(fileName)\""
            } else {
                return ""
            }
        }

        let prefixString = boundary
            + "\r\n"
            + "Content-Disposition: form-data; name=\"\(self.name)\"\(fileNameComponent)"
            + "\r\n"
            + "Content-Type: \(self.contentType)"
            + "\r\n"
            + "\r\n"

        return prefixString.data(using: .utf8)!
    }

    public func postfixData(usingBoundary boundary: String) -> Data {
        return "\r\n".data(using: .utf8)!
    }
}

public extension MultipartComponent {
    convenience init(fileURL: URL, name: String, fileName: String?, contentType: String) {
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        self.init(dataStream: InputStream(url: fileURL)!,
                  name: name,
                  fileName: fileName,
                  contentType: contentType,
                  streamLength: fileAttributes?[FileAttributeKey.size] as? Int ?? 0)
    }
    
    convenience init(data: Data, name: String, fileName: String?, contentType: String) {
        self.init(dataStream: InputStream(data: data),
                  name: name,
                  fileName: fileName,
                  contentType: contentType,
                  streamLength: data.count)
    }
}
