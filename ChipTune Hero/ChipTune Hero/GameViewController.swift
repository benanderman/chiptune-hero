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
  
  override func viewWillAppear(_ animated: Bool) {
    guard let song = songInfo else { fatalError() }
    guard let skview = view as? SKView else { fatalError() }
    guard let path = Bundle.main.path(forResource: song.filename, ofType: nil) else { fatalError() }
    game = Game(songPath: path, speedMultiplier: song.speedMultiplier)
    gameScene = GameScene(size: view.bounds.size, game: game)
    
    NotificationCenter.default.addObserver(self, selector: #selector(GameEnded), name: NSNotification.Name(rawValue: k.Notification.GameEnded), object: nil)
    
    gameScene?.isPaused = false
    skview.presentScene(gameScene)
    game.startGame()
  }
  
  func GameEnded() {
    gameScene?.isPaused = true
    self.dismiss(animated: true, completion: nil)
  }
  
  override open var shouldAutorotate: Bool {
    return true
  }
  
  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .allButUpsideDown
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override open var prefersStatusBarHidden: Bool {
    return true
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
