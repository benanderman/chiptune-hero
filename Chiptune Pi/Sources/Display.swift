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
  static let dataPin: Int32 = 4
  static let clockPin: Int32 = 20
  
  static func setup() {
    set_gpio_to_output(dataPin)
    set_gpio_to_output(clockPin)
  }
  
  static func setDisplay(data: [Bool]) {
    for bit in data {
      set_gpio_value(dataPin, bit)
      set_gpio_value(clockPin, true)
      set_gpio_value(clockPin, false)
    }
    set_gpio_value(clockPin, true)
    set_gpio_value(clockPin, false)
  }
}
