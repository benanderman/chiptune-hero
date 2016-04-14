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
  let buttonCount: Int
  let buttonColor: UIColor
  let activeColor: UIColor
  var touchesToButtons = [UITouch:Int]()
  var buttons = [SKSpriteNode]()
  
  weak var delegate: ButtonsNodeDelegate?
  
  init(color: UIColor, activeColor: UIColor, buttonCount: Int, size: CGSize) {
    self.buttonCount = buttonCount
    self.buttonColor = color
    self.activeColor = activeColor
    
    super.init(texture: nil, color: UIColor.clearColor(), size: size)
    
    let buttonSize = size.width / CGFloat(buttonCount)
    for i in 0 ..< 4 {
      let button = SKSpriteNode(color: color, size: CGSize(width: buttonSize, height: buttonSize))
      let y = buttonSize / 2 - size.height / 2
      button.position = CGPoint(x: (CGFloat(i) + 0.5) * buttonSize - (size.width / 2), y: y)
      addChild(button)
      buttons.append(button)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func buttonDown(buttonId: Int) {
    delegate?.buttonsNodeButtonDown(buttonId)
    buttons[buttonId].color = activeColor
  }
  
  func buttonUp(buttonId: Int) {
    delegate?.buttonsNodeButtonUp(buttonId)
    buttons[buttonId].color = buttonColor
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    for touch in touches {
      let buttonId = buttonIdForTouch(touch)
      touchesToButtons[touch] = buttonId
      buttonDown(buttonId)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesMoved(touches, withEvent: event)
    for touch in touches {
      let buttonId = buttonIdForTouch(touch)
      if buttonId != touchesToButtons[touch] {
        buttonUp(touchesToButtons[touch]!)
        buttonDown(buttonId)
        touchesToButtons[touch] = buttonId
      }
    }
  }
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    super.touchesCancelled(touches, withEvent: event)
    for buttonId in touchesToButtons.values {
      buttonUp(buttonId)
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    for touch in touches {
      buttonUp(touchesToButtons[touch]!)
    }
  }
  
  func buttonIdForTouch(touch: UITouch) -> Int {
    return Int((touch.locationInNode(self).x + size.width / 2) / (size.width / CGFloat(buttonCount)))
  }
}
