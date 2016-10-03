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
    
    super.init(texture: nil, color: UIColor.clear, size: size)
    
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
    delegate?.buttonsNodeButtonDown(buttonId: buttonId)
    buttons[buttonId].color = activeColor
  }
  
  func buttonUp(buttonId: Int) {
    delegate?.buttonsNodeButtonUp(buttonId: buttonId)
    buttons[buttonId].color = buttonColor
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    for touch in touches {
      let buttonId = buttonIdForTouch(touch: touch)
      touchesToButtons[touch] = buttonId
      buttonDown(buttonId: buttonId)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    for touch in touches {
      let buttonId = buttonIdForTouch(touch: touch)
      if buttonId != touchesToButtons[touch] {
        buttonUp(buttonId: touchesToButtons[touch]!)
        buttonDown(buttonId: buttonId)
        touchesToButtons[touch] = buttonId
      }
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    for buttonId in touchesToButtons.values {
      buttonUp(buttonId: buttonId)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    for touch in touches {
      buttonUp(buttonId: touchesToButtons[touch]!)
    }
  }
  
  func buttonIdForTouch(touch: UITouch) -> Int {
    return Int((touch.location(in: self).x + size.width / 2) / (size.width / CGFloat(buttonCount)))
  }
}
