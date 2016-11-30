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
  var lines = SKShapeNode()
  var lines2 = SKShapeNode()
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color.withAlphaComponent(0.5), size: size)
    setupLines()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupLines() {
    let lineCount = Int(size.height / size.width) + 4
    let path = CGMutablePath()
    let path2 = CGMutablePath()
    for i in 0 ... lineCount {
      let usePath = i % 4 == 0 ? path2 : path
      let y = CGFloat(i) * size.width - size.height / 2
      usePath.move(to: CGPoint(x: -size.width / 2, y: y))
      usePath.addLine(to: CGPoint(x: size.width / 2, y: y))
    }
    lines.path = path
    lines2.path = path2
    lines.strokeColor = UIColor(white: 0, alpha: 0.2)
    lines2.strokeColor = UIColor(white: 0, alpha: 0.5)
    lines2.lineWidth = 2
    addChild(lines)
    addChild(lines2)
  }
  
  func startBlock(beats: Int, rowId: Int) {
    let height: CGFloat = size.width * CGFloat(beats)
    let block = NoteNode(size: CGSize(width: size.width, height: height))
    block.rowId = rowId
    block.position = CGPoint(x: 0, y: -frame.size.height)
    block.name = "Block"
    block.zPosition = 5
    
    blocks.insert(block)
    addChild(block)
  }
  
  func updateBlockPositions(position: Double, currentRow: Int) {
    for block in blocks {
      block.active = block.rowId == currentRow
      let bottom = -frame.size.height / 2 + block.frame.height / 2
      block.position.y = bottom + block.frame.height * (CGFloat(block.rowId) - CGFloat(position))
      if block.position.y > frame.size.height {
        block.removeFromParent()
        blocks.remove(block)
      }
    }
    let pos = CGPoint(x: 0, y: (CGFloat(position).truncatingRemainder(dividingBy: 4.0)) * -size.width)
    lines.position = pos
    lines2.position = pos
  }
  
  func rowWasPlayed(row: Int, accuracy: Double) {
    for block in blocks {
      if (block.rowId == row) {
        let starSprite = SKSpriteNode(imageNamed: "Square")

        starSprite.setScale(0.5)
        starSprite.position = block.position
        blocks.remove(block)
        block.removeFromParent()
        
        addChild(starSprite)

        let emitter: SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "StarParticle", ofType: "sks")!) as! SKEmitterNode
        emitter.particlePosition = CGPoint(x: 0, y: starSprite.size.height)
        emitter.targetNode = self
        starSprite.addChild(emitter)

        let duration = TimeInterval(1.25)
        let doneAction = SKAction.fadeOut(withDuration: 5)
        let riseAction = SKAction.moveTo(y: 900, duration: duration)
        let spinAction = SKAction.rotate(byAngle: CGFloat(3.14 * duration * 3), duration: duration * 3)
        emitter.run(SKAction.fadeOut(withDuration: 1))
        starSprite.run(riseAction)
        starSprite.run(spinAction)
        
        starSprite.run(doneAction) {
          starSprite.removeFromParent()
        }
      }
    }
  }
  
  func failedToPlayRow(row: Int) {
    for block in blocks {
      if (block.rowId == row) {
        block.color = UIColor.red.withAlphaComponent(0.5)
      }
    }
  }
}

