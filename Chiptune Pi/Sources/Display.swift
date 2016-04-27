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
  static let columnPins: [Int32] = [5, 6, 13, 19]
  static let clockPin: Int32 = 20
  static let srClockPin: Int32 = 21
  
  static func setup() {
    for pin in columnPins {
      set_gpio_to_output(pin)
    }
    set_gpio_to_output(clockPin)
    set_gpio_to_output(srClockPin)
  }
  
  static func setDisplay(data: [[Bool]]) {
    for row in data {
      guard row.count <= columnPins.count else { fatalError("Too many rows!") }
      for i in 0 ..< row.count {
        set_gpio_value(columnPins[i], row[i])
      }
      set_gpio_value(srClockPin, true)
      set_gpio_value(srClockPin, false)
    }
    set_gpio_value(clockPin, true)
    set_gpio_value(clockPin, false)
  }
}
