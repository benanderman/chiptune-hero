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
  var songDifficulty: String?
  
  override func viewWillAppear(_ animated: Bool) {
    guard let song = songInfo else { fatalError() }
    guard let difficulty = songDifficulty else { fatalError() }
    guard let skview = view as? SKView else { fatalError() }
    guard let path = Bundle.main.path(forResource: song.filename, ofType: nil) else { fatalError() }
    let speed = ["easy": song.easySpeed, "hard": song.hardSpeed][difficulty]
    game = Game(songPath: path, speed: speed!)
    gameScene = GameScene(size: view.bounds.size, game: game)
    
    NotificationCenter.default.addObserver(self, selector: #selector(gameEnded), name: NSNotification.Name(rawValue: k.Notification.GameEnded), object: nil)
    
    gameScene?.isPaused = false
    skview.presentScene(gameScene)
    game.startGame()
  }
  
  func gameEnded() {
    gameScene?.isPaused = true
    if game.gameWon {
      guard let difficulty = songDifficulty else { fatalError() }
      let highScore = HighScoreInfo(score: game.score,
                                    maxScore: game.maxScore,
                                    notesHit: game.notesPlayed,
                                    totalNotes: game.totalNotes)
      _ = HighScoreManager.updateHighestScoreForSong(id: songInfo!.filename, difficulty: difficulty, highScore: highScore)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  override open var shouldAutorotate: Bool {
    return false
  }
  
  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
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
