//
//  PauseNode.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 12/30/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import SpriteKit

protocol PauseNodeDelegate: class {
  func pauseNodeQuitButtonTapped(pauseNode: PauseNode)
  func pauseNodeResumeButtonTapped(pauseNode: PauseNode)
}

class PauseNode: AlertNode {
  var quitButton: SKSpriteNode?
  var resumeButton: SKSpriteNode?
  
  weak var delegate: PauseNodeDelegate?
  
  init(game: Game) {
    let progressPercent = max(Int(Float(game.position) / Float(game.songLength) * 100), 0)
    let progressText = "Progress: \(progressPercent)%"
    
    super.init(title: "Game Paused", stats: [progressText])
    
    let buttonSize = CGSize(width: frame.size.width / 2.0, height: 50.0)
    let baseX = self.frame.minX
    let baseY = self.frame.minY
    quitButton = SKSpriteNode(texture: nil, color: UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0), size: buttonSize)
    resumeButton = SKSpriteNode(texture: nil, color: UIColor(red: 0.7, green: 1.0, blue: 0.7, alpha: 1.0), size: buttonSize)
    quitButton?.position = CGPoint(x: baseX + buttonSize.width / 2, y: baseY + buttonSize.height / 2)
    resumeButton?.position = CGPoint(x: baseX + buttonSize.width * 1.5, y: baseY + buttonSize.height / 2)
    
    let quitLabel = SKLabelNode(text: "Quit")
    quitLabel.verticalAlignmentMode = .center
    quitLabel.fontColor = .black
    quitLabel.fontName = "Menlo-Regular"
    quitLabel.fontSize = 18
    quitButton!.addChild(quitLabel)
    
    let resumeLabel = SKLabelNode(text: "Resume")
    resumeLabel.verticalAlignmentMode = .center
    resumeLabel.fontColor = .black
    resumeLabel.fontName = "Menlo-Regular"
    resumeLabel.fontSize = 18
    resumeButton!.addChild(resumeLabel)
    
    addChild(quitButton!)
    addChild(resumeButton!)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard touches.count == 1 else { return }
    let touch = touches.first!
    let location = touch.location(in: self)
    if nodes(at: location).contains(quitButton!) {
      delegate?.pauseNodeQuitButtonTapped(pauseNode: self)
    } else if nodes(at: location).contains(resumeButton!) {
      delegate?.pauseNodeResumeButtonTapped(pauseNode: self)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
