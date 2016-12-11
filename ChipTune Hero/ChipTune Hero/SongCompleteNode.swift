//
//  SongCompleteNode.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 12/7/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

class SongCompleteNode: SKSpriteNode {
  init(score: Int, longestStreak: Int, stars: Int, totalNotes: Int, notesPlayed: Int) {
    super.init(texture: nil, color: UIColor(white: 1.0, alpha: 0.85), size: CGSize(width: 250, height: 250))
    
    let padding = CGFloat(15.0)
    
    let titleNode = SKLabelNode(text: "Song Complete!")
    titleNode.fontColor = .black
    titleNode.fontName = "Menlo-Bold"
    titleNode.horizontalAlignmentMode = .center
    titleNode.verticalAlignmentMode = .top
    titleNode.fontSize = 24
    titleNode.position = CGPoint(x: 0, y: frame.maxY - padding)
    self.addChild(titleNode)
    
    let notesPercent = Int(Float(notesPlayed) / Float(totalNotes) * 100)
    let stats = [
      "Longest streak: \(longestStreak)",
      "Score: \(score)",
      "Notes played: \(notesPercent)%"]
    
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
      lastNode = labelNode
    }
    
    let continueNode = SKLabelNode(text: "Tap to continue")
    continueNode.fontColor = .black
    continueNode.fontName = "Menlo-Bold"
    continueNode.horizontalAlignmentMode = .center
    continueNode.verticalAlignmentMode = .bottom
    continueNode.fontSize = 18
    continueNode.position = CGPoint(x: 0, y: frame.minY + 10)
    self.addChild(continueNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
