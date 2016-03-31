//
//  GameScene.swift
//  ChipTuneHeroGame
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright (c) 2016 Todd Olsen. All rights reserved.
//

import SpriteKit

private struct k {
  struct Name {
    static let ChannelName = "ChipTuneHero-Channel"
  }
  
  struct Color {
    static let Channels = [UIColor.redColor(),
                           UIColor.blueColor(),
                           UIColor.purpleColor(),
                           UIColor.greenColor()]
    static let Window   = UIColor(white: 0.0, alpha: 0.3)
  }
}

class GameScene: SKScene, GameDelegate, ButtonsNodeDelegate {
  let channelCount = 4
  var channels = [ChannelNode]()
  var lastAddedRow = 0
  var buttonsNode: ButtonsNode
  weak var game: Game!
  
  init(size: CGSize, game: Game) {
    
    let channelWidth = size.width / CGFloat(channelCount)
    let channelSize = CGSizeMake(channelWidth - 2, size.height)
    
    self.game = game
    
    for i in 0 ..< channelCount {
      let channel = ChannelNode(color: k.Color.Channels[i], size: channelSize)
      channels.append(channel)
    }
    
    buttonsNode = ButtonsNode(texture: nil, color: k.Color.Window, size: CGSize(width: size.width, height: channelWidth))
    
    super.init(size: size)
    
    self.game.delegate = self
    
    for i in 0 ..< channelCount {
      self.channels[i].position = CGPointMake(channelWidth * (0.5 + CGFloat(i)), frame.midY)
      self.channels[i].name = "\(k.Name.ChannelName)\(i)"
      addChild(self.channels[i])
    }
    
    buttonsNode.position = CGPoint(x: frame.midX, y: buttonsNode.size.height / 2)
    buttonsNode.zPosition = 6
    buttonsNode.userInteractionEnabled = true
    buttonsNode.delegate = self
    self.addChild(buttonsNode)
  }
  
  override func update(currentTime: NSTimeInterval) {
    let position = game.position
    
    let rowsOnScreen = Int(frame.height / channels[0].frame.width) + 1
    if lastAddedRow < Int(position) + rowsOnScreen - 1 {
      for i in lastAddedRow + 1 ..< Int(position) + rowsOnScreen {
        let row = game.notes[i]
        for channelIndex in row {
          channels[channelIndex].startBlock(1, rowId: i)
        }
      }
    }
    lastAddedRow = Int(position) + rowsOnScreen - 1
    
    for i in 0 ..< 4 {
      channels[i].updateBlockPositions(position)
    }
  }
  
  func gameDidPlayRow(game: Game, row: Int) {
    for channel in channels {
      channel.rowWasPlayed(row)
    }
  }
  
  func gameDidFailRow(game: Game, row: Int) {
    for channel in channels {
      channel.failedToPlayRow(row)
    }
  }
  
  func buttonsNodeButtonDown(buttonId: Int) {
    game.buttonDown(Game.Button(rawValue: buttonId)!)
  }
  
  func buttonsNodeButtonUp(buttonId: Int) {
    game.buttonUp(Game.Button(rawValue: buttonId)!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
