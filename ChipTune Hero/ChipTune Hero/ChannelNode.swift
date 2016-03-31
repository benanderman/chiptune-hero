//
//  ChannelNode.swift
//  ChipTuneHeroGame
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit

class ChannelNode: SKSpriteNode {
  
  var blocks = Set<NoteNode>()
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color.colorWithAlphaComponent(0.5), size: size)
    self.zPosition = 1
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startBlock(beats: Int, rowId: Int) {
    let height: CGFloat = size.width * CGFloat(beats)
    let block = NoteNode(color: UIColor(white: 1.0, alpha: 0.9), size: CGSizeMake(size.width, height))
    block.rowId = rowId
    block.position = CGPointMake(0, -frame.size.height)
    block.name = "Block"
    block.zPosition = 5
    
    blocks.insert(block)
    addChild(block)
  }
  
  func updateBlockPositions(position: Double) {
    for block in blocks {
      let bottom = -frame.size.height / 2 + block.frame.height / 2
      block.position.y = bottom + block.frame.height * (CGFloat(block.rowId) - CGFloat(position))
      if block.position.y > frame.size.height {
        block.removeFromParent()
        blocks.remove(block)
      }
    }
  }
  
  func rowWasPlayed(row: Int) {
    for block in blocks {
      if (block.rowId == row) {
        let starSprite = SKSpriteNode(imageNamed: "Star")

        starSprite.setScale(0.5)
        starSprite.position = block.position
        blocks.remove(block)
        block.removeFromParent()
        
        addChild(starSprite)

        let emitter: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("StarParticle", ofType: "sks")!) as! SKEmitterNode
        emitter.particlePosition = CGPointMake(0, starSprite.size.height)
        emitter.targetNode = self
        starSprite.addChild(emitter)

        let duration = NSTimeInterval(1.25)
        let doneAction = SKAction.fadeOutWithDuration(5)
        let riseAction = SKAction.moveToY(900, duration: duration)
        let spinAction = SKAction.rotateByAngle(CGFloat(3.14 * duration * 3), duration: duration * 3)
        emitter.runAction(SKAction.fadeOutWithDuration(1))
        starSprite.runAction(riseAction)
        starSprite.runAction(spinAction)
        
        starSprite.runAction(doneAction) {
          starSprite.removeFromParent()
        }
      }
    }
  }
  
  func failedToPlayRow(row: Int) {
    for block in blocks {
      if (block.rowId == row) {
        block.color = UIColor.redColor().colorWithAlphaComponent(0.5)
      }
    }
  }
}

