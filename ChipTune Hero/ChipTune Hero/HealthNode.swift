//
//  HealthNode.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/31/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

class HealthNode: SKSpriteNode {
  var shade: SKSpriteNode
  
  init() {
    let size = CGSize(width: 15, height: 100)
    shade = SKSpriteNode(color: UIColor(white: 0, alpha: 0.8), size: CGSize(width: size.width, height: 0))
    
    super.init(texture: nil, color: UIColor.clearColor(), size: size)
    
    let border = SKShapeNode(rectOfSize: CGSize(width: size.width + 2, height: size.height + 2))
    border.strokeColor = UIColor.blackColor()
    border.fillColor = UIColor(white: 0, alpha: 0.3)
    border.zPosition = 1
    self.addChild(border)
    
    for i in 0 ..< 16 {
      let percent = CGFloat(i) / 15
      let color = UIColor(hue: (1 - percent) * (120 / 360), saturation: 1.0, brightness: 0.8, alpha: 1.0)
      let sprite = SKSpriteNode(color: color, size: CGSize(width: size.width, height: size.height / 16))
      sprite.position = CGPoint(x: frame.midX, y: frame.maxY - sprite.size.height * (CGFloat(i) + 0.5))
      sprite.zPosition = 2
      self.addChild(sprite)
    }
    
    shade.anchorPoint = CGPoint(x: 0, y: 0)
    shade.position = CGPoint(x: frame.minX, y: frame.maxY)
    shade.zPosition = 3
    self.addChild(shade)
  }
  
  func setHealth(health: Double) {
    let roundedHealth = round(health * 16) / 16
    shade.size.height = frame.height - (frame.height * CGFloat(roundedHealth))
    shade.position.y = size.height / 2 - shade.size.height
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
