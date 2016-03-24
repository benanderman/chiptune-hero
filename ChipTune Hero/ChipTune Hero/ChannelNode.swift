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
        
        self.window.position = CGPointMake(0, -size.height/2 + size.width/2)
        self.window.zPosition = zPosition + 10
        self.window.userInteractionEnabled = false
        self.window.name = "Window"
        
        self.userInteractionEnabled = true
        
        self.addChild(self.window)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startBlock() {
        
        let block = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(size.width, size.width))
        block.position = CGPointMake(0, frame.midY + frame.width)
        block.name = "Block"
        block.zPosition = 5
        
        addChild(block)
        block.runAction(SKAction.moveToY(-frame.midY - frame.width, duration: 1.0)) {
            block.removeFromParent()
        }
    }
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if let block = childNodeWithName("Block") {
            if self.window.intersectsNode(block) {
                
                let starSprite = SKSpriteNode(imageNamed: "filled_star")
                
                starSprite.setScale(0.6)
                starSprite.position = window.position
                addChild(starSprite)
                
                let emitter: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("StarParticle", ofType: "sks")!) as! SKEmitterNode
                emitter.particlePosition = CGPointMake(0, -starSprite.size.height)
                emitter.targetNode = self
                starSprite.addChild(emitter)
                
                let doneAction = SKAction.fadeOutWithDuration(1.5)
                starSprite.runAction(doneAction) {
                    starSprite.removeFromParent()
                }
                
                return
            }
        }
        
        print("Fail!")

    }
}

