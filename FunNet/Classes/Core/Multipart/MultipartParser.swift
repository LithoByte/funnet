////
////  MultipartParser.swift
////  FunNet
////
////  Created by William Collins on 12/19/20.
////
//
//import Foundation
//public final class MultipartParser {
//  public var onHeader: (String, String) -> ()
//  public var onBody: (inout InputStream) -> ()
//  public var onPartComplete: () -> ()
//
//  private var callbacks: multipartparser_callbacks
//  private var parser: multipartparser
//
//  private enum HeaderState {
//    case ready
//    case field(field: String)
//    case value(field: String, value: String)
//  }
//
//  private var headerState: HeaderState
//
//  /// Creates a new `MultipartParser`.
//  public init(boundary: String) {
//    self.onHeader = { _, _ in }
//    self.onBody = { _ in }
//    self.onPartComplete = { }
//
//    var parser = multipartparser()
//    multipartparser_init(&parser, boundary)
//    var callbacks = multipartparser_callbacks()
//    multipartparser_callbacks_init(&callbacks)
//    self.callbacks = callbacks
//    self.parser = parser
//    self.headerState = .ready
//    self.callbacks.on_header_field = { parser, data, size in
//      guard let context = Context.from(parser) else {
//        return 1
//      }
//      let string = String(cPointer: data, count: size)
//      context.parser.handleHeaderField(string)
//      return 0
//    }
//    self.callbacks.on_header_value = { parser, data, size in
//      guard let context = Context.from(parser) else {
//        return 1
//      }
//      let string = String(cPointer: data, count: size)
//      context.parser.handleHeaderValue(string)
//      return 0
//    }
//    self.callbacks.on_data = { parser, data, size in
//      guard let context = Context.from(parser) else {
//        return 1
//      }
//      var buffer = context.slice(at: data, count: size)
//      context.parser.handleData(&buffer)
//      return 0
//    }
//    self.callbacks.on_body_begin = { parser in
//      return 0
//    }
//    self.callbacks.on_headers_complete = { parser in
//      guard let context = Context.from(parser) else {
//        return 1
//      }
//      context.parser.handleHeadersComplete()
//      return 0
//    }
//    self.callbacks.on_part_end = { parser in
//      guard let context = Context.from(parser) else {
//        return 1
//      }
//      context.parser.handlePartEnd()
//      return 0
//    }
//    self.callbacks.on_body_end = { parser in
//      return 0
//    }
//  }
//
//  struct Context {
//    static func from(_ pointer: UnsafeMutablePointer<multipartparser>?) -> Context? {
//      guard let parser = pointer?.pointee else {
//        return nil
//      }
//      return parser.data.assumingMemoryBound(to: MultipartParser.Context.self).pointee
//    }
//
//    unowned let parser: MultipartParser
//    let unsafeBuffer: UnsafeRawBufferPointer
//    let buffer: ByteBuffer
//
//    func slice(at pointer: UnsafePointer<Int8>?, count: Int) -> ByteBuffer {
//      guard let pointer = pointer else {
//        fatalError("no data pointer")
//      }
//      guard let unsafeBufferStart = unsafeBuffer.baseAddress?.assumingMemoryBound(to: Int8.self) else {
//        fatalError("no base address")
//      }
//      let unsafeBufferEnd = unsafeBufferStart.advanced(by: unsafeBuffer.count)
//      if pointer >= unsafeBufferStart && pointer <= unsafeBufferEnd {
//        // we were given back a pointer inside our buffer, we can be efficient
//        let offset = unsafeBufferStart.distance(to: pointer)
//        guard let buffer = self.buffer.getSlice(at: offset, length: count) else {
//          fatalError()
//        }
//        return buffer
//      } else {
//        // the buffer is to somewhere else, like a statically allocated string
//        // let's create a new buffer
//        let bytes = UnsafeRawBufferPointer(
//          start: UnsafeRawPointer(pointer),
//          count: count
//        )
//        var buffer = ByteBuffer(capacity: bytes.count)
//        buffer.writeFromPointer(pointer: bytes)
//        return buffer
//      }
//    }
//  }
//
//  public func execute(_ string: String) throws {
//    try self.execute([UInt8](string.utf8))
//  }
//
//  public func execute<T>(_ data: T) throws
//    where T: DataProtocol
//  {
//    var buffer = ByteBuffer(data: data)
//    return try self.execute(buffer)
//  }
//
//  public func execute(_ buffer: ByteBuffer) throws {
//    let result = buffer.withUnsafeReadableBytes { (unsafeBuffer: UnsafeRawBufferPointer) -> Int in
//      var context = Context(parser: self, unsafeBuffer: unsafeBuffer, buffer: buffer)
//      return withUnsafeMutablePointer(to: &context) { (contextPointer: UnsafeMutablePointer<Context>) -> Int in
//        self.parser.data = .init(contextPointer)
//        return multipartparser_execute(&self.parser, &self.callbacks, unsafeBuffer.baseAddress?.assumingMemoryBound(to: Int8.self), unsafeBuffer.count)
//      }
//    }
//    guard result == buffer.readableBytes else {
//      throw MultipartError.invalidFormat
//    }
//  }
//
//  // MARK: Private
//  private func handleHeaderField(_ new: String) {
//    switch self.headerState {
//    case .ready:
//      self.headerState = .field(field: new)
//    case .field(let existing):
//      self.headerState = .field(field: existing + new)
//    case .value(let field, let value):
//      self.onHeader(field, value)
//      self.headerState = .field(field: new)
//    }
//  }
//
//  private func handleHeaderValue(_ new: String) {
//    switch self.headerState {
//    case .field(let name):
//      self.headerState = .value(field: name, value: new)
//    case .value(let name, let existing):
//      self.headerState = .value(field: name, value: existing + new)
//    default: fatalError()
//    }
//  }
//
//  private func handleHeadersComplete() {
//    switch self.headerState {
//    case .value(let field, let value):
//      self.onHeader(field, value)
//      self.headerState = .ready
//    case .ready: break
//    default: fatalError()
//    }
//  }
//
//  private func handleData(_ data: inout ByteBuffer) {
//    var input = data.toInputStream()!
//    self.onBody(&input)
//  }
//
//  private func handlePartEnd() {
//    self.onPartComplete()
//  }
//}
//
//private extension String {
//  init(cPointer: UnsafePointer<Int8>?, count: Int) {
//    let pointer = UnsafeRawPointer(cPointer)?.assumingMemoryBound(to: UInt8.self)
//    self.init(decoding: UnsafeBufferPointer(start: pointer, count: count), as: UTF8.self)
//  }
//}
