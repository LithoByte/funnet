//
//  MultipartSerializer.swift
//  FunNet
//
//  Created by Elliot Schrock on 8/18/20.
//

import Foundation

/// Serializes `MultipartForm`s to `Data`.
///
/// See `MultipartParser` for more information about the multipart encoding.
public final class MultipartSerializer {
    /// Creates a new `MultipartSerializer`.
    public init() { }

    public func serialize(parts: [MultipartComponent], boundary: String) throws -> String {
        var buffer = try ByteBuffer(data: nil)
        try self.serialize(parts: parts, boundary: boundary, into: &buffer)
      return String(decoding: buffer.buffer, as: UTF8.self)
    }

    /// Serializes the `MultipartForm` to data.
    ///
    ///     let data = try MultipartSerializer().serialize(parts: [part], boundary: "123")
    ///     print(data) // multipart-encoded
    ///
    /// - parameters:
    ///     - parts: One or more `MultipartPart`s to serialize into `Data`.
    ///     - boundary: Multipart boundary to use for encoding. This must not appear anywhere in the encoded data.
    /// - throws: Any errors that may occur during serialization.
    /// - returns: `multipart`-encoded `Data`.
    public func serialize(parts: [MultipartComponent], boundary: String, into buffer: inout ByteBuffer) throws {
        for part in parts {
          
          buffer.writeString(string: "--")
          buffer.writeString(string: boundary)
          buffer.writeString(string: "\r\n")
          buffer.writeString(string: String(data: part.prefixData(usingBoundary: boundary), encoding: .utf8)!)
          buffer.writeString(string:"\r\n")
          let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: part.streamLength)
          defer {
              temp.deallocate()
          }
          while part.dataStream.hasBytesAvailable {
            let read = part.dataStream.read(temp, maxLength: part.streamLength)
            if (read < 0) {
              //Stream error occurred
              
              throw part.dataStream.streamError!
            }
            else if (read == 0) {
              // EOF
              break
            }
          }
          
          let tempBuffer = UnsafeRawBufferPointer(start: temp, count: part.streamLength)
          buffer.writeFromPointer(pointer: tempBuffer)
          
//            for (key, val) in part.headers {
//                buffer.writeString(key)
//                buffer.writeString(": ")
//                buffer.writeString(val)
//                buffer.writeString("\r\n")
//            }
          
//            var body = part.body
//            buffer.writeBuffer(&body)
          buffer.writeString(string: "\r\n")
        }
      buffer.writeString(string: "--")
      buffer.writeString(string: boundary)
      buffer.writeString(string: "--\r\n")
    }
}

