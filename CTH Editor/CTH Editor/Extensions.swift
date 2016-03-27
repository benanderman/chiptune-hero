//
//  Extensions.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/27/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation
import Cocoa

extension NotesLayer.Color {
  var nsColor: NSColor {
    return NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
  }
  
  init(nsColor: NSColor) {
    self.init(red: Double(nsColor.redComponent),
              green: Double(nsColor.greenComponent),
              blue: Double(nsColor.blueComponent),
              alpha: Double(nsColor.alphaComponent))
  }
}
