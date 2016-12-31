//
//  SongCompleteNode.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 12/7/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

class SongCompleteNode: AlertNode {
  init(game: Game, won: Bool) {
    
    var stats: [String]
    if won {
      let notesPercent = Int(Float(game.notesPlayed) / Float(game.totalNotes) * 100)
      stats = [
        "Longest streak: \(game.longestStreak)",
        "Score: \(game.score)",
        "Notes played: \(notesPercent)%"]
    } else {
      let progressPercent = max(Int(Float(game.position) / Float(game.songLength) * 100), 0)
      stats = [
        "Score: \(game.score)",
        "Progress: \(progressPercent)%"]
    }
    
    super.init(title: won ? "Song Complete!" : "Song Failed!", stats: stats)
    
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
