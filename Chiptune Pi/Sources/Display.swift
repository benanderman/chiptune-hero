//
//  Display.swift
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/7/16.
//
//

import Foundation
import Glibc

struct Display {
  static let dataPin: Int32 = 5
  static let clockPin: Int32 = 20
  static let srClockPin: Int32 = 21
  
  static let numRows = 16
  
  static func setup() {
    set_gpio_to_output(dataPin)
    set_gpio_to_output(clockPin)
    set_gpio_to_output(srClockPin)
  }
  
  static func setDisplay(data: [[Bool]]) {
    guard data.count >= numRows else { fatalError("Too many rows!") }
    for row in data[data.count - numRows ..< data.count] {
      for value in row {
        set_gpio_value(dataPin, value)
        set_gpio_value(srClockPin, true)
        set_gpio_value(srClockPin, false)
      }
    }
    set_gpio_value(clockPin, true)
    set_gpio_value(clockPin, false)
  }
}
