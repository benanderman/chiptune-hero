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

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let skview = view as? SKView else { fatalError() }
    
    let path = NSBundle.mainBundle().pathForResource("a_winter_kiss.xm", ofType: nil)
    game = Game(songPath: path!)
    
    skview.presentScene(GameScene(size: view.bounds.size, game: game))
    
    game.startGame()
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
}
