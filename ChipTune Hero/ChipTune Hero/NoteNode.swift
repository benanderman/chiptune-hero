//
//  NoteNode.swift
//  ChipTune Hero
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

class NoteNode: SKSpriteNode {
  var rowId = 0
  
  let border: SKSpriteNode
  let block: SKSpriteNode
  
  var active = false {
    didSet {
      block.color = block.color.withAlphaComponent(active ? 1.0 : 0.75)
    }
  }
  
  init(size: CGSize) {
    border = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0.4), size: CGSize(width: size.width - 10, height: size.height - 10))
    block = SKSpriteNode(color: UIColor(white: 1.0, alpha: 0.75), size: CGSize(width: size.width - 20, height: size.height - 20))
    super.init(texture: nil, color: UIColor.clear, size: size)
    addChild(border)
    addChild(block)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
    return nil
  }
}
