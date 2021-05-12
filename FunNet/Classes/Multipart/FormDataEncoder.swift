//
//  FormDataEncoder.swift
//  FunNet
//
//  Created by Elliot Schrock on 8/18/20.
//

import Foundation

/// Errors that can be thrown while working with Multipart.
public enum MultipartError: Error, CustomStringConvertible {
  case invalidFormat
  case convertibleType(Any.Type)
  case convertiblePart(Any.Type, MultipartComponent)
  case nesting
  case missingPart(String)
  case missingFilename
  
  public var description: String {
    switch self {
    case .invalidFormat:
      return "Multipart data is not formatted correctly"
    case .convertibleType(let type):
      return "\(type) is not convertible to multipart data"
    case .convertiblePart(let type, let part):
      return "Multipart part is not convertible to \(type): \(part)"
    case .nesting:
      return "Nested multipart data is not supported"
    case .missingPart(let name):
      return "No multipart part named '\(name)' was found"
    case .missingFilename:
      return "Multipart part did not have a filename"
    }
  }
}


// Encodes `Encodable` items to `multipart/form-data` encoded `Data`.
//
// See [RFC#2388](https://tools.ietf.org/html/rfc2388) for more information about `multipart/form-data` encoding.
//
// Seealso `MultipartParser` for more information about the `multipart` encoding.
public struct FormDataEncoder {
  /// Creates a new `FormDataEncoder`.
  public init() { }
  
  public func encode(_ encodable: Encodable, boundary: String = "--boundary-\(Date().timeIntervalSince1970)-boundary--") throws -> MultipartFormData {
    let multipart = FormDataEncoderContext()
    let encoder = _FormDataEncoder(multipart: multipart, codingPath: [])
    try encodable.encode(to: encoder)
    return MultipartFormData(parts: multipart.parts, boundary: boundary)
  }
}

// MARK: Private
private final class FormDataEncoderContext {
  var parts: [MultipartComponent]
  init() {
    self.parts = []
  }
  
  func encode<E>(_ encodable: E, at codingPath: [CodingKey], arrayIndex i: Int? = nil) throws where E: Encodable {
    guard let convertible = encodable as? MultipartConvertible else {
      throw MultipartError.convertibleType(E.self)
    }
    
    let multipart = convertible.multipart
    var name: String = ""
    var fileName: String? = nil
    switch codingPath.count {
    case 0: throw MultipartError.invalidFormat
    case 1: name = camelToSnake(string: codingPath[0].stringValue) ?? codingPath[0].stringValue
    default:
      let nestedName = makeName(codingPath: codingPath, index: 1, name: codingPath[0].stringValue)
      name = camelToSnake(string: nestedName) ?? nestedName
    }
    if let i = i {
        fileName = "\(name)[\(i)]"
    }
    let part = multipart(name, fileName, nil)
    self.parts.append(part)
  }
}

private struct _FormDataEncoder: Encoder {
  let codingPath: [CodingKey]
  let multipart: FormDataEncoderContext
  var userInfo: [CodingUserInfoKey: Any] {
    return [:]
  }
  
  init(multipart: FormDataEncoderContext, codingPath: [CodingKey]) {
    self.multipart = multipart
    self.codingPath = codingPath
  }
  
  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return KeyedEncodingContainer(_FormDataKeyedEncoder(multipart: multipart, codingPath: codingPath))
  }
  
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    return _FormDataUnkeyedEncoder(multipart: multipart, codingPath: codingPath)
  }
  
  func singleValueContainer() -> SingleValueEncodingContainer {
    return _FormDataSingleValueEncoder(multipart: multipart, codingPath: codingPath)
  }
}

private struct _FormDataSingleValueEncoder: SingleValueEncodingContainer {
  let multipart: FormDataEncoderContext
  var codingPath: [CodingKey]
  
  init(multipart: FormDataEncoderContext, codingPath: [CodingKey]) {
    self.multipart = multipart
    self.codingPath = codingPath
  }
  
  mutating func encodeNil() throws {
    // do nothing
  }
  
  mutating func encode<T>(_ value: T) throws where T : Encodable {
    try multipart.encode(value, at: codingPath)
  }
}

private struct _FormDataKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
  let multipart: FormDataEncoderContext
  var codingPath: [CodingKey]
  
  init(multipart: FormDataEncoderContext, codingPath: [CodingKey]) {
    self.multipart = multipart
    self.codingPath = codingPath
  }
  
  mutating func encodeNil(forKey key: K) throws {
    // ignore
  }
  
  mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
    if value is MultipartConvertible {
      try multipart.encode(value, at: codingPath + [key])
    } else {
      let encoder = _FormDataEncoder(multipart: multipart, codingPath: codingPath + [key])
      try value.encode(to: encoder)
    }
  }
  
  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
    return KeyedEncodingContainer(_FormDataKeyedEncoder<NestedKey>(multipart: multipart, codingPath: codingPath + [key]))
  }
  
  mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
    return _FormDataUnkeyedEncoder(multipart: multipart, codingPath: codingPath + [key])
  }
  
  mutating func superEncoder() -> Encoder {
    return _FormDataEncoder(multipart: multipart, codingPath: codingPath)
  }
  
  mutating func superEncoder(forKey key: K) -> Encoder {
    return _FormDataEncoder(multipart: multipart, codingPath: codingPath + [key])
  }
}

private struct _FormDataUnkeyedEncoder: UnkeyedEncodingContainer {
  var count: Int
  let multipart: FormDataEncoderContext
  var codingPath: [CodingKey]
  var index: CodingKey {
    return BasicCodingKey.index(count)
  }
  
  init(multipart: FormDataEncoderContext, codingPath: [CodingKey]) {
    self.multipart = multipart
    self.codingPath = codingPath
    count = 0
  }
  
  mutating func encodeNil() throws {
    // ignore
  }
  
  mutating func encode<T>(_ value: T) throws where T : Encodable {
    if value is MultipartConvertible {
        try multipart.encode(value, at: codingPath + [index], arrayIndex: count)
    } else {
        let encoder = _FormDataEncoder(multipart: multipart, codingPath: codingPath + [index])
        try value.encode(to: encoder)
    }
    count += 1
  }
  
  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    return KeyedEncodingContainer(_FormDataKeyedEncoder<NestedKey>(multipart: multipart, codingPath: codingPath + [index]))
  }
  
  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    return _FormDataUnkeyedEncoder(multipart: multipart, codingPath: codingPath + [index])
  }
  
  mutating func superEncoder() -> Encoder {
    return _FormDataEncoder(multipart: multipart, codingPath: codingPath + [index])
  }
}
