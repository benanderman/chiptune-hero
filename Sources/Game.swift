//
//  Game.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/29/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
  func gameDidPlayRow(game: Game, row: Int)
  func gameDidFailRow(game: Game, row: Int)
  func gameDidLose(game: Game)
  func gameDidWin(game: Game)
}

class Game: SongPlayerDelegate {
  enum Button: Int {
    case One = 0
    case Two
    case Three
    case Four
  }
  
  weak var delegate: GameDelegate?
  
  var notes: NotesLayer {
    return songPlayer.songSpec?.playable ?? NotesLayer(rows: 0)
  }
  
  var position: Double {
    let elapsed = NSDate().timeIntervalSince1970 - lastRowChange
    return Double(songPlayer.globalRow) + min(1, elapsed / lastRowTime)
  }
  
  var gameEnded = false
  
  var currentRow: Int {
    var rowId = Int(position)
    rowId += position - Double(rowId) > 0.5 ? 1 : 0
    return rowId
  }
  
  // MARK: Stats
  var notesPlayed: Int {
    return notesPlayedOrMissed.reduce(0) { $0 + ($1 == true ? 1 : 0) }
  }
  var notesMissed: Int {
    return notesPlayedOrMissed.reduce(0) { $0 + ($1 == false ? 1 : 0) }
  }
  
  var streak: Int {
    return notesPlayedOrMissed.reversed().reduce((sum: 0, foundMissed: false)) {
      if $1 && !$0.foundMissed {
        return (sum: $0.sum + 1, foundMissed: false)
      } else {
        return (sum: $0.sum, foundMissed: true)
      }
    }.sum
  }
  
  var multiplier: Int {
    return min(streak / 10 + 1, 5)
  }
  
  var health: Double {
    return Double(healthInternal) / Double(Game.maxHealth)
  }
  
  var score = 0
  
  init(songPath: String, speedMultiplier: Int) {
    self.speedMultiplier = speedMultiplier
    songPlayer.delegate = self
    songPlayer.openSong(path: songPath)
    let specPath = songPath + ".spec.json"
    if let data = FileManager.default.contents(atPath: specPath) {
      #if USE_SWIFTYJSON
        let json = JSON(data: data)
        songPlayer.songSpec = SongSpec(json: json)
      #else
        let dict = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
        songPlayer.songSpec = SongSpec(dict: dict)
      #endif
    }
  }
  
  func startGame() {
    lastRowChange = NSDate().timeIntervalSince1970
    songPlayer.startPlaying()
    songPlayer.speed = songPlayer.speed! * speedMultiplier
  }
  
  func update() {
    songPlayer.update()
  }
  
  func loseGame() {
    gameEnded = true
    songPlayer.stop()
    delegate?.gameDidLose(game: self)
  }
  
  func winGame() {
    gameEnded = true
    delegate?.gameDidWin(game: self)
  }
  
  func buttonDown(button: Button) {
    guard gameEnded == false else { return }
    buttonsDown.insert(button)
    checkIfRowPlayed()
  }
  
  func buttonUp(button: Button) {
    guard gameEnded == false else { return }
    buttonsDown.remove(button)
  }
  
  func songPlayerPositionChanged(songPlayer: SongPlayer) {
    let now = NSDate().timeIntervalSince1970
    lastRowTime = now - lastRowChange
    lastRowChange = now
    let lastRow = Int(position - 1)
    if notes[lastRow].count > 0 && lastRowPlayed != lastRow {
      handleFailedToPlayRow(row: lastRow)
    }
  }
  
  func songPlayerSongEnded(songPlayer: SongPlayer) {
    winGame()
  }
  
  // MARK: Private
  private let songPlayer = SongPlayer()
  private let speedMultiplier: Int
  private var buttonsDown = Set<Button>()
  private var lastRowChange: TimeInterval = 0
  private var lastRowTime: TimeInterval = 1
  private var lastRowPlayed = 0
  private var notesPlayedOrMissed = [Bool]()
  private var rowsMissed = [Int:Int]()
  private static let maxHealth = 200
  private var healthInternal = Int(Float(maxHealth) * 0.75)
  
  private func checkIfRowPlayed() {
    let rowId = currentRow
    let row = Set(notes[rowId])
    let buttons = Set(buttonsDown.map { $0.rawValue })
    if lastRowPlayed == rowId {
      handleFailedToPlayRow(row: rowId)
      return
    }
    if buttons == row {
      handlePlayedRow(row: rowId)
    } else if buttons.subtracting(row).count != 0 {
      // The player pressed a wrong button
      handleFailedToPlayRow(row: rowId)
    }
  }
  
  private func handleFailedToPlayRow(row: Int) {
    songPlayer.playChannels = .Inactive
    notesPlayedOrMissed.append(false)
    
    // Lose 3 health the first time you miss a row, 1 the second time, 0 subsequent times
    // The 0 is mainly to deal with multi-note rows causing you to lose lots of health
    var healthLoss = 3
    var newMissed = 1
    if let missed = rowsMissed[row] {
      healthLoss = missed == 1 ? 1 : 0
      newMissed = 2
    }
    rowsMissed[row] = newMissed
    healthInternal = max(0, healthInternal - healthLoss)
    
    checkLoseCondition()
    delegate?.gameDidFailRow(game: self, row: row)
  }
  
  private func handlePlayedRow(row: Int) {
    lastRowPlayed = row
    songPlayer.playChannels = .Custom
    for i in 0 ..< (songPlayer.totalChannels ?? 0) {
      songPlayer.setChannelMute(channel: i, mute: false)
    }
    notesPlayedOrMissed.append(true)
    healthInternal = min(Game.maxHealth, healthInternal + 2 * multiplier)
    score += multiplier
    delegate?.gameDidPlayRow(game: self, row: row)
  }
  
  private func checkLoseCondition() {
    if health == 0 {
      loseGame()
    }
  }
}
