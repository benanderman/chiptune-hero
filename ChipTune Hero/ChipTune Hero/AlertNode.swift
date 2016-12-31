//
//  AlertNode.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 12/30/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

class AlertNode: SKSpriteNode {
  let padding = CGFloat(15.0)
  
  var titleNode: SKLabelNode
  var statNodes = [SKLabelNode]()
  
  init(title: String, stats: [String]) {
    titleNode = SKLabelNode(text: title)
    
    super.init(texture: nil, color: UIColor(white: 1.0, alpha: 0.85), size: CGSize(width: 250, height: 250))
    
    titleNode.fontColor = .black
    titleNode.fontName = "Menlo-Bold"
    titleNode.horizontalAlignmentMode = .center
    titleNode.verticalAlignmentMode = .top
    titleNode.fontSize = 24
    titleNode.position = CGPoint(x: 0, y: frame.maxY - padding)
    self.addChild(titleNode)
    
    var lastNode = titleNode
    for stat in stats {
      let labelNode = SKLabelNode(text: stat)
      labelNode.fontColor = .black
      labelNode.fontName = "Menlo-Regular"
      labelNode.horizontalAlignmentMode = .left
      labelNode.verticalAlignmentMode = .top
      labelNode.fontSize = 18
      labelNode.position = CGPoint(x: frame.minX + padding, y: lastNode.frame.minY - padding)
      self.addChild(labelNode)
      statNodes.append(labelNode)
      lastNode = labelNode
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
