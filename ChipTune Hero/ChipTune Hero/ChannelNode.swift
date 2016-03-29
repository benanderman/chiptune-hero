//
//  ChannelNode.swift
//  ChipTuneHeroGame
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit

class ChannelNode: SKSpriteNode {
  
  let window: SKSpriteNode
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    
    self.window = SKSpriteNode(texture: nil, color: k.Color.Window, size: CGSizeMake(size.width, size.width))
    super.init(texture: texture, color: color, size: size)
    
    self.window.position = CGPointMake(0, -size.height/2 + window.size.width/2)
    self.window.zPosition = zPosition + 10
    self.window.userInteractionEnabled = false
    self.window.name = "Window"
    
    self.userInteractionEnabled = true
    self.zPosition = 1
    self.addChild(self.window)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startBlock(beats: Int) {
    
    let height: CGFloat = size.width * CGFloat(beats)
    let block = NoteNode(color: UIColor(white: 1.0, alpha: 0.9), size: CGSizeMake(size.width, height))
    block.position = CGPointMake(0, frame.midY + frame.width + height/2)
    block.name = "Block"
    block.zPosition = 5
    
    addChild(block)
    
    let x = k.Time.Fall/Double(arc4random_uniform(8))
    block.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.scaleBy(0.95, duration: x), SKAction.scaleBy(1.05, duration: x)])))
    block.runAction(SKAction.moveToY(-frame.midY - frame.width, duration: k.Time.Fall)) {
      block.removeFromParent()
    }
  }
  
  var startSuccess = false
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    guard let block = childNodeWithName("Block") as? NoteNode else { return }
    
    if self.window.intersectsNode(block) {
      startSuccess = true
      return
    }
    
    block.color = UIColor.redColor()
    startSuccess = false
    
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    if let block = childNodeWithName("Block") as? NoteNode {
      if self.window.intersectsNode(block) && startSuccess {
        let starSprite = SKSpriteNode(imageNamed: "Star")
        
        starSprite.setScale(0.5)
        starSprite.position = window.position
        addChild(starSprite)
        
        let emitter: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("StarParticle", ofType: "sks")!) as! SKEmitterNode
        emitter.particlePosition = CGPointMake(0, starSprite.size.height)
        emitter.targetNode = self
        starSprite.addChild(emitter)
        
        let doneAction = SKAction.fadeOutWithDuration(5)
        let riseAction = SKAction.moveToY(900, duration: k.Time.Fall)
        let spinAction = SKAction.rotateByAngle(CGFloat(3.14 * k.Time.Fall * 3), duration: k.Time.Fall * 3)
        emitter.runAction(SKAction.fadeOutWithDuration(1))
        starSprite.runAction(riseAction)
        starSprite.runAction(spinAction)
        
        starSprite.runAction(doneAction) {
          starSprite.removeFromParent()
        }
        return
      }
      
      block.color = UIColor.redColor()
      
    }
  }
}

