//
//  ButtonsNode.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/30/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

protocol ButtonsNodeDelegate: class {
  func buttonsNodeButtonDown(buttonId: Int)
  func buttonsNodeButtonUp(buttonId: Int)
}

class ButtonsNode : SKSpriteNode {
  var buttonCount = 4
  var touchesToButtons = [UITouch:Int]()
  
  weak var delegate: ButtonsNodeDelegate?
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    for touch in touches {
      let buttonId = buttonIdForTouch(touch)
      touchesToButtons[touch] = buttonId
      delegate?.buttonsNodeButtonDown(buttonId)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesMoved(touches, withEvent: event)
    for touch in touches {
      let buttonId = buttonIdForTouch(touch)
      if buttonId != touchesToButtons[touch] {
        delegate?.buttonsNodeButtonUp(touchesToButtons[touch]!)
        delegate?.buttonsNodeButtonDown(buttonId)
        touchesToButtons[touch] = buttonId
      }
    }
  }
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    super.touchesCancelled(touches, withEvent: event)
    for buttonId in touchesToButtons.values {
      delegate?.buttonsNodeButtonUp(buttonId)
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    for touch in touches {
      delegate?.buttonsNodeButtonUp(touchesToButtons[touch]!)
    }
  }
  
  func buttonIdForTouch(touch: UITouch) -> Int {
    return Int((touch.locationInNode(self).x + size.width / 2) / (size.width / CGFloat(buttonCount)))
  }
}
