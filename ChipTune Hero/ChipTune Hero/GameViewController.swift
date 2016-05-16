//
//  GameViewController.swift
//  ChipTuneHeroGame
//
//  Created by Todd Olsen on 3/24/16.
//  Copyright (c) 2016 Todd Olsen. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  var game: Game!
  var gameScene: GameScene?
  var songInfo: SongInfo?
  
  override func viewWillAppear(animated: Bool) {
    guard let song = songInfo else { fatalError() }
    guard let skview = view as? SKView else { fatalError() }
    guard let path = NSBundle.mainBundle().pathForResource(song.filename, ofType: nil) else { fatalError() }
    game = Game(songPath: path, speedMultiplier: song.speedMultiplier)
    gameScene = GameScene(size: view.bounds.size, game: game)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameEnded), name: k.Notification.GameEnded, object: nil)
    
    gameScene?.paused = false
    skview.presentScene(gameScene)
    game.startGame()
  }
  
  func GameEnded() {
    gameScene?.paused = true
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return .AllButUpsideDown
    } else {
      return .All
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}
