//
//  FormDataEncoder+Name.swift
//  FunNet
//
//  Created by William Collins on 12/22/20.
//

import Foundation

/**
 Takes an ordered array of CodingKeys and converts them into nested format:
 Pre: codingPath.count >= 1
 [user, invitation, from] => "user[invitation[from]]"
 */

public func makeName(codingPath: [CodingKey], index: Int, name: String) -> String {
  if index > (codingPath.count - 1) {
    return name
  } else {
    let key = codingPath[index]
    if let intValue = key.intValue {
      return makeName(codingPath: codingPath, index: index+1, name: name + "[]")
    } else {
      let string = key.stringValue
      return makeName(codingPath: codingPath, index: index+1, name: name + "[\(string)]")
    }
  }
  
}


/**
 For testing makeName: ([CodingKey], Int, String) -> String
 */
public func makeName(strings: [String], index: Int, name: String) -> String {
  if index > (strings.count - 1) {
    return name
  } else {
    let key = strings[index]
    return makeName(strings: strings, index: index+1, name: name + "[\(key)]")
  }
}
