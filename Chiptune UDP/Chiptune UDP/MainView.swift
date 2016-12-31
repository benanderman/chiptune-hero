//
//  MainView.swift
//  Chiptune UDP
//
//  Created by Ben Anderman on 12/28/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Cocoa

protocol MainViewDelegate: class {
  func buttonDown(button: Game.Button)
  func buttonUp(button: Game.Button)
}

class MainView: NSView {
  weak var delegate: MainViewDelegate?
  
  let keysToButtons: [String:Game.Button] = ["h": .One,
                                             "j": .Two,
                                             "k": .Three,
                                             "l": .Four]
  
  override func keyDown(with event: NSEvent) {
    guard event.isARepeat == false else { return }
    if event.characters != nil && keysToButtons[event.characters!] != nil {
      delegate?.buttonDown(button: keysToButtons[event.characters!]!)
    }
  }
  
  override func keyUp(with event: NSEvent) {
    if event.characters != nil && keysToButtons[event.characters!] != nil {
      delegate?.buttonUp(button: keysToButtons[event.characters!]!)
    }
  }
  
  override var acceptsFirstResponder: Bool {
    return true
  }
}
