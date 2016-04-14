//
//  GameManager.swift
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/7/16.
//
//

import Foundation
import Glibc

class GameManager: GameDelegate {
  let game: Game
  
  init(path: String) {
    game = Game(songPath: "../songs/a_winter_kiss.xm")
    game.delegate = self
  }
  
  func run() {
    game.startGame()
    
    Display.setup()
    
    set_gpio_to_input(17)
    var oldValue = true
    var oldPosition = game.position
    
    while true {
      game.update()
      
      var ts = timespec(tv_sec: 0, tv_nsec: 5_000_000)
      var ret = timespec()
      nanosleep(&ts, &ret)
      
      let value = get_gpio_value(17)
      if value != oldValue {
        if value {
          game.buttonDown(.One)
        } else {
          game.buttonUp(.One)
        }
        oldValue = value
      }
      
      let position = game.position
      if position != oldPosition {
//        let row = game.notes[Int(round(position))]
//        set_gpio_value(4, row.contains(0))
        let intPos = Int(round(position))
        var col = [Bool]()
        for i in intPos ..< intPos + 9 {
          col.append(game.notes[i].contains(0))
          col.append(game.notes[i].contains(0))
        }
        let offset = 1 - (intPos - Int(position))
        col = [Bool](col[0 + offset ..< col.count - (2 - offset)])
        Display.setDisplay(col)
        oldPosition = position
      }
    }
  }
  
  func gameDidPlayRow(game: Game, row: Int) {
    print("😇  Played row: \(row)")
  }
  
  func gameDidFailRow(game: Game, row: Int) {
    print("😡  Failed row: \(row)")
  }
  
  func gameDidLose(game: Game) {
    print("💩  Game over")
  }
  
  func gameDidWin(game: Game) {
    print("👌  Game won")
  }
}
