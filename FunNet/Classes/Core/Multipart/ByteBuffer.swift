///
//
// Calvin Collins
// Lithobyte.co
//
///
import Foundation

public struct ByteBuffer {
  var buffer: UnsafeMutableRawBufferPointer
  var count: Int {
    get {
      return buffer.count
    }
  }
  public init(data: Data?) throws {
    guard let data = data else { fatalError() }
    self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: data.count, alignment: 1)
    data.copyBytes(to: buffer)
  }
  
  public init(capacity: Int) {
    self.buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: capacity, alignment: 1)
  }
  
  public func toInputStream() -> InputStream?{
    return InputStream(data: Data(buffer))
  }
  
  public mutating func writeString(string: String) {
    let ints: [UInt8] = [UInt8](string.data(using: .utf8)!)
    print(ints)
    let newBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: ints.count + count, alignment: MemoryLayout<UInt8>.alignment)
    newBuffer.copyBytes(from: buffer)
    for byte in newBuffer.enumerated() {
      print(byte)
    }
    print(newBuffer.count)
    for i in 0..<ints.count {
      newBuffer.storeBytes(of: ints[i], toByteOffset: i + buffer.count, as: UInt8.self)
    }
    buffer.deallocate()
    
    buffer = newBuffer
  }
  
  public func getSlice(at offset: Int, length: Int) -> ByteBuffer? {
    let temp: ByteBuffer? = try? buffer.withUnsafeBytes({ bytes in
      let data = Data(bytes)
      return try ByteBuffer(data: data)
    })
    return temp
  }
  
  public mutating func writeFromPointer(pointer: UnsafeRawBufferPointer) {
    let newBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: pointer.count + count, alignment: MemoryLayout<UInt8>.alignment)
    newBuffer.copyBytes(from: buffer)
    for byte in newBuffer.enumerated() {
      print(byte)
    }
    print(newBuffer.count)
    for i in 0..<pointer.count {
      newBuffer.storeBytes(of: pointer.load(fromByteOffset: i, as: UInt8.self), toByteOffset: i + buffer.count, as: UInt8.self)
    }
    buffer.deallocate()
    
    buffer = newBuffer
  }
  
  public func read<E>(at offset: Int) -> E {
    
    let newBuffer = buffer.load(fromByteOffset: offset, as: E.self)
    print(newBuffer)
    return newBuffer
  }
  
  public func printAll() {
    for (offset, byte) in buffer.enumerated() {
      print("offset: \(offset), byte: \(byte), char: \(Character(UnicodeScalar(byte)))")
    }
  }
  
}
