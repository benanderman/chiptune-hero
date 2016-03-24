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
}

class GameScene: SKScene {
    
    let channel1: ChannelNode
    let channel2: ChannelNode
    let channel3: ChannelNode
    let channel4: ChannelNode
    
    override init(size: CGSize) {
        
        let channelWidth = size.width/4
        let channelSize = CGSizeMake(channelWidth, size.height)
        
        self.channel1 = ChannelNode(color: k.Color.Channel1, size: channelSize)
        self.channel2 = ChannelNode(color: k.Color.Channel2, size: channelSize)
        self.channel3 = ChannelNode(color: k.Color.Channel3, size: channelSize)
        self.channel4 = ChannelNode(color: k.Color.Channel4, size: channelSize)
        
        super.init(size: size)

        self.channel1.position = CGPointMake(channelWidth * 0.5, self.frame.midY)
        self.channel1.zPosition = 1
        self.channel1.name = k.Name.Channel1
        
        self.channel2.position = CGPointMake(channelWidth * 1.5, self.frame.midY)
        self.channel2.zPosition = 1
        self.channel2.name = k.Name.Channel2
        
        self.channel3.position = CGPointMake(channelWidth * 2.5, self.frame.midY)
        self.channel3.zPosition = 1
        self.channel3.name = k.Name.Channel3
        
        self.channel4.position = CGPointMake(channelWidth * 3.5, self.frame.midY)
        self.channel4.zPosition = 1
        self.channel4.name = k.Name.Channel4
        
        addChild(self.channel1)
        addChild(self.channel2)
        addChild(self.channel3)
        addChild(self.channel4)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var startTime: CFTimeInterval = 0
   
    override func update(currentTime: CFTimeInterval) {

        if startTime == 0 {
            startTime = currentTime
            print(startTime)
        }
        
        if (Int(currentTime * 100) - Int(startTime * 100)) % 25 == 0 {
            
            let channel = [channel1, channel2, channel3, channel4][Int(arc4random_uniform(UInt32(4)))]
            sendBlockOnChannel(channel)
            
        }
    }
    
    func sendBlockOnChannel(channel: ChannelNode) {
        channel.startBlock()
    }
}
