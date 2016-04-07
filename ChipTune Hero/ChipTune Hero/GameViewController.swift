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
  var songName: String?
  
  override func viewWillAppear(animated: Bool) {
    guard let skview = view as? SKView else { fatalError() }
    
    let path = NSBundle.mainBundle().pathForResource(songName, ofType: nil)
    game = Game(songPath: path!)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameEnded), name: k.Notification.GameEnded, object: nil)
    
    skview.presentScene(GameScene(size: view.bounds.size, game: game))
    game.startGame()
  }
  
  func GameEnded() {
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
