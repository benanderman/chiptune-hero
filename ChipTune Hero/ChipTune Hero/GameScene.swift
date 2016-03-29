//
//  GameScene.swift
//  ChipTuneHeroGame
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright (c) 2016 Todd Olsen. All rights reserved.
//

import SpriteKit

public struct k {
  
  public struct Name {
    public static let Channel1 = "ChipTuneHero-Channel1"
    public static let Channel2 = "ChipTuneHero-Channel2"
    public static let Channel3 = "ChipTuneHero-Channel3"
    public static let Channel4 = "ChipTuneHero-Channel4"
  }
  
  public struct Color {
    public static let Channel1 = UIColor.redColor()
    public static let Channel2 = UIColor.blueColor()
    public static let Channel3 = UIColor.purpleColor()
    public static let Channel4 = UIColor.greenColor()
    public static let Window   = UIColor(white: 0.3, alpha: 0.3)
  }
  
  public struct Time {
    public static let Fall = NSTimeInterval(1.25)
  }
  
}

struct ChannelGenerator {
  
  let channel: ChannelNode
  let beats: Int
  let intervalCount: Int
  let startOn: Bool
  
  init(channel: ChannelNode, beats: Int, intervalCount: Int, startOn: Bool) {
    self.channel = channel
    self.beats = beats
    self.intervalCount = intervalCount
    self.startOn = startOn
    
    isOn = startOn
    interval = intervalCount
  }
  
  var isOn: Bool
  var interval: Int
  
  mutating func next() {
    
    if isOn {
      channel.startBlock(beats)
    }
    
    interval -= 1
    if interval < 0 {
      isOn = !isOn
      interval = intervalCount
    }
    
    let hue = CGFloat(Double(arc4random_uniform(120) + 90)/Double(255))
    let sat = CGFloat(Double(arc4random_uniform(120) + 100)/Double(255))
    let bri = CGFloat(Double(arc4random_uniform(120) + 50)/Double(255))
    
    channel.color = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1.0)
  }
}

class GameScene: SKScene {
  
  let channel1: ChannelNode
  let channel2: ChannelNode
  let channel3: ChannelNode
  let channel4: ChannelNode
  
  var timer1: NSTimer!
  
  override init(size: CGSize) {
    
    let channelWidth = size.width/4
    let channelSize = CGSizeMake(channelWidth - 2, size.height)
    
    self.channel1 = ChannelNode(color: k.Color.Channel1, size: channelSize)
    self.channel2 = ChannelNode(color: k.Color.Channel2, size: channelSize)
    self.channel3 = ChannelNode(color: k.Color.Channel3, size: channelSize)
    self.channel4 = ChannelNode(color: k.Color.Channel4, size: channelSize)
    
    super.init(size: size)
    
    self.channel1.position = CGPointMake(channelWidth * 0.5, self.frame.midY)
    self.channel1.name = k.Name.Channel1
    
    self.channel2.position = CGPointMake(channelWidth * 1.5, self.frame.midY)
    self.channel2.name = k.Name.Channel2
    
    self.channel3.position = CGPointMake(channelWidth * 2.5, self.frame.midY)
    self.channel3.name = k.Name.Channel3
    
    self.channel4.position = CGPointMake(channelWidth * 3.5, self.frame.midY)
    self.channel4.name = k.Name.Channel4
    
    addChild(self.channel1)
    addChild(self.channel2)
    addChild(self.channel3)
    addChild(self.channel4)
    
    
    
    var ch1 = ChannelGenerator(channel: channel1, beats: 1, intervalCount: 8, startOn: true)
    var ch2 = ChannelGenerator(channel: channel2, beats: 2, intervalCount: 4, startOn: false)
    var ch3 = ChannelGenerator(channel: channel3, beats: 1, intervalCount: 7, startOn: false)
    var ch4 = ChannelGenerator(channel: channel4, beats: 2, intervalCount: 5, startOn: true)
    
    
    NSTimer.every(k.Time.Fall/4.second) {
      ch1.next()
      ch2.next()
      ch3.next()
      ch4.next()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func sendChannel1Block() {
    print("Hello")
  }
  
  
  
  func sendBlockOnChannel(channel: ChannelNode) {
    //        channel.startBlock()
  }
}
