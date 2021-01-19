//
//  MultipartConvertible.swift
//  FunNet
//
//  Created by William Collins on 12/20/20.
//

import Foundation

public protocol MultipartConvertible {
  /**
   Takes name, fileName, and ContentType for header construction
   */
  var multipart: ((String, String?, String?) -> MultipartComponent) { get }
  init?(multipart: MultipartComponent)
}

extension MultipartComponent: MultipartConvertible {
  public var multipart: (String, String?, String?) -> MultipartComponent {
    get {
      return { _, _, _ in
        return self
      }
    }
  }
  
  public convenience init?(multipart: MultipartComponent) {
    self.init(dataStream: multipart.dataStream, name: multipart.name, fileName: multipart.fileName, contentType: multipart.contentType, streamLength: multipart.streamLength)
  }
}

extension String: MultipartConvertible {
  public var multipart: ((String, String?, String?) -> MultipartComponent) {
    get {
      return { name, fileName, _ in
        MultipartComponent(data: self.data(using: .utf8)!, name: name, fileName: fileName, contentType: "text/plain")
      }
    }
  }
  
  public init?(multipart: MultipartComponent) {
    let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: multipart.streamLength)
    let byteCount = multipart.dataStream.read(temp, maxLength: multipart.streamLength)
    
    defer {
      temp.deinitialize(count: multipart.streamLength)
      temp.deallocate()
    }
    if (byteCount < multipart.streamLength) {
      return nil
    } else {
      self.init(utf8String: temp.withMemoryRebound(to: CChar.self, capacity: multipart.streamLength, { $0 }))
    }
  }
}

extension FixedWidthInteger {
  public var multipart: ((String, String?, String?) -> MultipartComponent) {
    get {
      return { name, fileName, _ in
        MultipartComponent(data: self.description.data(using: .utf8)!, name: name, fileName: fileName, contentType: "text/plain")
      }
    }
  }
  
  public init?(multipart: MultipartComponent) {
    guard let string = String(multipart: multipart) else {
      return nil
    }
    self.init(string)
  }
}

extension Int: MultipartConvertible { }
extension Int8: MultipartConvertible { }
extension Int16: MultipartConvertible { }
extension Int32: MultipartConvertible { }
extension Int64: MultipartConvertible { }
extension UInt: MultipartConvertible { }
extension UInt8: MultipartConvertible { }
extension UInt16: MultipartConvertible { }
extension UInt32: MultipartConvertible { }
extension UInt64: MultipartConvertible { }

extension Float: MultipartConvertible {
  public var multipart: ((String, String?, String?) -> MultipartComponent) {
    get {
      return { name, fileName, _ in
        MultipartComponent(data: self.description.data(using: .utf8)!, name: name, fileName: fileName, contentType: "text/plain")
      }
    }
  }
  
  public init?(multipart: MultipartComponent) {
    guard let string = String(multipart: multipart) else {
      return nil
    }
    self.init(string)
  }
}

extension Double: MultipartConvertible {
    public var multipart: ((String, String?, String?) -> MultipartComponent) {
      get {
        return { name, fileName, _ in
          MultipartComponent(data: self.description.data(using: .utf8)!, name: name, fileName: nil, contentType: "text/plain")
        }
      }
    }
    
    public init?(multipart: MultipartComponent) {
      guard let string = String(multipart: multipart) else {
        return nil
      }
      self.init(string)
    }
}

extension Bool: MultipartConvertible {
  public var multipart: ((String, String?, String?) -> MultipartComponent) {
    get {
      return { name, fileName, _ in
        MultipartComponent(data: self.description.data(using: .utf8)!, name: name, fileName: fileName, contentType: "text/plain")
      }
    }
  }
  
  public init?(multipart: MultipartComponent) {
    guard let string = String(multipart: multipart) else {
        return nil
    }
    self.init(string)
  }
}

extension Data: MultipartConvertible {
  public var multipart: ((String, String?, String?) -> MultipartComponent) {
    return { name, fileName, contentType in
      MultipartComponent(data: self, name: name, fileName: fileName, contentType: contentType ?? "application/octet-stream")
    }
  }
  
  public init?(multipart: MultipartComponent) {
    let stream = multipart.dataStream
    try? self.init(reading: stream)
  }
}

extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}

extension URL: MultipartConvertible {
  public var multipart: ((String, String?, String?) -> MultipartComponent) {
    return { name, fileName, contentType in
      MultipartComponent(fileURL: self, name: name, fileName: self.pathComponents.last, contentType: self.mimeType())
    }
  }
  
  public init?(multipart: MultipartComponent) {
    return nil
  }
  
  
}

public final class PngImage: UIImage { }

extension PngImage: MultipartConvertible, Codable {
    public var multipart: ((String, String?, String?) -> MultipartComponent) {
        return { name, fileName, contentType in
            MultipartComponent(data: self.pngData()!, name: name, fileName: fileName, contentType: "image/png")
        }
    }
    
    public convenience init?(multipart: MultipartComponent) {
        guard let data = try? Data(reading: multipart.dataStream) else { return nil }
        self.init(data: data)
    }
}

public final class JpgImage: UIImage {
    var quality: CGFloat = 1.0
}

extension JpgImage: MultipartConvertible, Codable {
    public var multipart: ((String, String?, String?) -> MultipartComponent) {
        return { [unowned self] name, fileName, contentType in
            MultipartComponent(data: self.jpegData(compressionQuality: self.quality) ?? Data(), name: name, fileName: fileName ?? "\(name).jpg", contentType: "image/jpeg")
        }
    }
    
    public convenience init?(multipart: MultipartComponent) {
        guard let data = try? Data(reading: multipart.dataStream) else { return nil }
        self.init(data: data)
    }
}

extension UIImage {
    public func jpgImage(ofQuality quality: CGFloat = 1.0) -> JpgImage? {
        if let cgImage = cgImage {
            let jpg = JpgImage(cgImage: cgImage)
            jpg.quality = quality
            return jpg
        }
        return nil
    }
}
