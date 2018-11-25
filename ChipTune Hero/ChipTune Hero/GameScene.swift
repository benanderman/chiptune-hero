//
//  GameScene.swift
//  ChipTuneHeroGame
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright (c) 2016 Todd Olsen. All rights reserved.
//

import SpriteKit

struct k {
  struct Name {
    static let ChannelName = "ChipTuneHero-Channel"
  }
  
  struct Color {
    static let Channels        = [UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.8),
                                  UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 0.8),
                                  UIColor(red: 0.8, green: 0.3, blue: 0.8, alpha: 0.8),
                                  UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 0.8),]
    static let Buttons         =  UIColor(white: 0.0, alpha: 0.3)
    static let ButtonsActive   =  UIColor(white: 1.0, alpha: 0.3)
  }
  
  struct Notification {
    static let GameEnded = "GameEnded"
  }
}

class GameScene: SKScene, GameDelegate, ButtonsNodeDelegate {
  let channelCount = 4
  var lastAddedRow = -1
  var game: Game!
  var gameEnded = false
  
  var channels = [ChannelNode]()
  var buttonsNode: ButtonsNode
  var healthNode: HealthNode
  var scoreNode: SKLabelNode
  var streakNode: SKLabelNode
  var multiplierNode: SKSpriteNode
  var pauseNode: PauseNode?
  
  init(size: CGSize, game: Game) {
    
    let channelWidth = size.width / CGFloat(channelCount)
    let channelSize = CGSize(width: channelWidth - 2, height: size.height)
    
    self.game = game
    
    for i in 0 ..< channelCount {
      let channel = ChannelNode(color: k.Color.Channels[i], size: channelSize)
      channels.append(channel)
    }
    
    buttonsNode = ButtonsNode(color: k.Color.Buttons,
                              activeColor: k.Color.ButtonsActive,
                              buttonCount: 4,
                              size: CGSize(width: size.width, height: channelWidth * 1.5))
    healthNode = HealthNode()
    scoreNode = SKLabelNode(text: "\(game.score)")
    streakNode = SKLabelNode(text: "\(game.streak)")
    multiplierNode = SKSpriteNode(texture: GameScene.textureForMultiplier(multiplier: game.multiplier))
    
    super.init(size: size)
    
    self.game.delegate = self
    
    for i in 0 ..< channelCount {
      self.channels[i].position = CGPoint(x: channelWidth * (0.5 + CGFloat(i)), y: frame.midY)
      self.channels[i].name = "\(k.Name.ChannelName)\(i)"
      addChild(self.channels[i])
    }
    
    buttonsNode.position = CGPoint(x: frame.midX, y: buttonsNode.size.height / 2)
    buttonsNode.zPosition = 6
    buttonsNode.isUserInteractionEnabled = true
    buttonsNode.delegate = self
    self.addChild(buttonsNode)
    
    healthNode.setHealth(health: game.health)
    healthNode.position = CGPoint(x: size.width - healthNode.size.width, y: size.height - healthNode.size.height / 2 - healthNode.size.width / 2)
    healthNode.zPosition = 7
    self.addChild(healthNode)
    
    multiplierNode.position = CGPoint(x: 10 + multiplierNode.size.width / 2, y: size.height - 10 - multiplierNode.size.height / 2)
    multiplierNode.zPosition = 8
    self.addChild(multiplierNode)
    
    streakNode.horizontalAlignmentMode = .left
    streakNode.verticalAlignmentMode = .top
    streakNode.fontSize = 18
    streakNode.fontName = "Menlo-Regular"
    streakNode.position = CGPoint(x: 10, y: multiplierNode.frame.minY - 10)
    streakNode.zPosition = 9
    self.addChild(streakNode)
    
    scoreNode.horizontalAlignmentMode = .left
    scoreNode.verticalAlignmentMode = .top
    scoreNode.fontSize = 18
    scoreNode.fontName = "Menlo-Regular"
    scoreNode.position = CGPoint(x: 10, y: streakNode.frame.minY - 10)
    scoreNode.zPosition = 10
    self.addChild(scoreNode)
  }
  
  override func update(_ currentTime: TimeInterval) {
    guard gameEnded == false else { return }
    let position = game.position
    
    let rowsOnScreen = Int(frame.height / channels[0].frame.width) + 1
    if lastAddedRow < Int(position) + rowsOnScreen - 1 {
      for i in lastAddedRow + 1 ..< Int(position) + rowsOnScreen {
        let row = game.notes[i]
        for channelIndex in row {
          guard channelIndex < channels.count else { continue }
          channels[channelIndex].startBlock(beats: 1, rowId: i)
        }
      }
    }
    lastAddedRow = Int(position) + rowsOnScreen - 1
    
    let currentRow = game.currentRow
    for i in 0 ..< 4 {
      channels[i].updateBlockPositions(position: position, currentRow: currentRow)
    }
  }
  
  static func textureForMultiplier(multiplier: Int) -> SKTexture {
    return SKTexture(imageNamed: "multiplier_\(multiplier)")
  }
  
  func gameDidPlayRow(game: Game, row: Int, accuracy: Double) {
    for channel in channels {
      channel.rowWasPlayed(row: row, accuracy: accuracy)
    }
    healthNode.setHealth(health: game.health)
    scoreNode.text = "\(game.score)"
    streakNode.text = "\(game.streak)"
    multiplierNode.texture = GameScene.textureForMultiplier(multiplier: game.multiplier)
  }
  
  func gameDidFailRow(game: Game, row: Int) {
    for channel in channels {
      channel.failedToPlayRow(row: row)
    }
    streakNode.text = "\(game.streak)"
    multiplierNode.texture = GameScene.textureForMultiplier(multiplier: game.multiplier)
    healthNode.setHealth(health: game.health)
  }
  
  func gameDidLose(game: Game) {
    endGame(won: false)
  }
  
  func gameDidWin(game: Game) {
    endGame(won: true)
  }
  
  func endGame(won: Bool) {
    guard gameEnded == false else { return }
    gameEnded = true
    let songCompleteNode = SongCompleteNode(game: game, won: won)
    songCompleteNode.position = CGPoint(x: frame.midX, y: frame.midY)
    songCompleteNode.zPosition = 99
    self.addChild(songCompleteNode)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameEnded {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: k.Notification.GameEnded), object: self)
    } else {
      guard touches.count == 1 else { return }
      let touch = touches.first!
      let location = touch.location(in: self)
      if location.y > 180 {
        if let pauseNode = pauseNode {
          pauseNode.removeFromParent()
          self.pauseNode = nil
        } else {
          let pauseNode = PauseNode(game: game)
          pauseNode.delegate = self
          pauseNode.position = CGPoint(x: frame.midX, y: frame.midY)
          pauseNode.zPosition = 99
          pauseNode.isUserInteractionEnabled = true
          addChild(pauseNode)
          self.pauseNode = pauseNode
        }
        game.togglePaused()
      }
    }
    super.touchesBegan(touches, with: event)
  }
  
  func buttonsNodeButtonDown(buttonId: Int) {
    game.buttonDown(button: Game.Button(rawValue: buttonId)!)
  }
  
  func buttonsNodeButtonUp(buttonId: Int) {
    game.buttonUp(button: Game.Button(rawValue: buttonId)!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension GameScene: PauseNodeDelegate {
  func pauseNodeQuitButtonTapped(pauseNode: PauseNode) {
    game.endGame()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k.Notification.GameEnded), object: self)
  }
  
  func pauseNodeResumeButtonTapped(pauseNode: PauseNode) {
    pauseNode.removeFromParent()
    self.pauseNode = nil
    game.togglePaused()
  }
}
