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
  let buttonPins: [Int32] = [18, 23, 24, 25]
  
  init(path: String) {
    game = Game(songPath: path)
    game.delegate = self
  }
  
  func run() {
    game.startGame()
    
    Display.setup()
    
    for pin in buttonPins {
      set_gpio_to_input(pin)
    }
    
    var oldButtonValues = [Bool](count: 4, repeatedValue: true)
    var oldPosition = game.position
    
    while true {
      game.update()
      
      if game.gameEnded {
        break
      }
      
      var ts = timespec(tv_sec: 0, tv_nsec: 10_000_000)
      var ret = timespec()
      nanosleep(&ts, &ret)
      
      for i in 0 ..< 4 {
        let value = get_gpio_value(buttonPins[i])
        if value != oldButtonValues[i] {
          if value {
            game.buttonDown(Game.Button(rawValue: i)!)
          } else {
            game.buttonUp(Game.Button(rawValue: i)!)
          }
          oldButtonValues[i] = value
        }
      }
      
      let position = round(game.position * 2) / 2
      if position != oldPosition {
        let intPos = Int(round(position))
        var cols = [[Bool]]()
        for i in intPos ..< intPos + 9 {
          let row = game.notes[i].reduce([false, false, false, false]) {
            var result = $0
            result[$1] = true
            return result
          }
          cols.append(row)
          cols.append(row)
        }
        let offset = 1 - (intPos - Int(position))
        cols = [[Bool]](cols[0 + offset ..< cols.count - (2 - offset)])
        Display.setDisplay(cols)
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
