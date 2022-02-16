//
//  CamelToSnake.swift
//  FunNet
//
//  Created by William Collins on 12/20/20.
//

import Foundation
import LithoOperators
public func camelToSnake(string: String) -> String? {
  let uppercases: [UInt8] = Array(0x41 ..< 0x5A)
  let lowercases: [UInt8] = Array(0x61 ..< 0x7A)
  guard var data = string.data(using: .utf8) else { return nil }
  let underscore: UInt8 = 0x5f
  var i = 0
  while i < data.count - 1 {
    if (i == 0) {
      if (uppercases.contains(data[i])) {
        data[i] += 32
      }
      i += 1
      continue
    }
    if uppercases.contains(data[i]){
      data[i] += 32
      if lowercases.contains(data[i+1]) {
        data.insert(underscore, at: i)
        i += 2
      } else {
        i += 1
      }
    } else {
      i += 1
    }
  }
  return String(bytes: data, encoding: .utf8)
}

public func camelFromSnake(string: String) -> String? {
  guard var data = string.data(using: .utf8) else { return nil }
  let underscore: UInt8 = 0x5f
  var i = 0
  while i < data.count - 1 {
    if (data[i] == underscore) {
      let next = data.remove(at: i + 1)
      data[i] = next - 32
      i += 1
    } else {
      i += 1
    }
  }
  return String(bytes: data, encoding: .utf8)
}
