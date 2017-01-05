//
//  Game.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/29/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
  func gameDidPlayRow(game: Game, row: Int, accuracy: Double)
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
    var row = songPlayer.globalRow
    if !introFinished {
      row = -introRowCount + row
    }

    return Double(row) + min(1, elapsed / lastRowTime)
  }
  
  var gameEnded = false
  var gameWon = false
  
  // The current row which should be played
  var currentRow: Int {
    var midRow = Int(position)
    midRow += position - Double(midRow) > 0.5 ? 1 : 0
    
    let candidates = [midRow - 1, midRow, midRow + 1]
    var result = midRow
    for row in candidates {
      let distance = abs(Double(row) - position)
      
      guard distance < Game.noteHitThreshold else { continue }
      guard row >= 0 && row < songPlayer.totalRows else { continue }
      guard row > lastRowPlayed else { continue }
      guard notes[row].count > 0 else { continue }
      
      result = row
      break
    }
    return result
  }
  
  // MARK: Stats
  var notesPlayed: Int {
    return notesPlayedOrMissed.reduce(0) { $0 + ($1 == true ? 1 : 0) }
  }
  var notesMissed: Int {
    return notesPlayedOrMissed.reduce(0) { $0 + ($1 == false ? 1 : 0) }
  }
  
  var totalNotes: Int {
    return notes.notes.reduce(0) { $0 + ($1 == nil ? 0 : 1) }
  }
  
  var maxScore: Int {
    var result = 0
    var noteCount = totalNotes
    for multiplier in 1 ..< Game.maxMultiplier {
      result += min(noteCount, 10) * multiplier
      noteCount -= 10
      if noteCount <= 0 {
        return result
      }
    }
    result += noteCount * Game.maxMultiplier
    return result
  }
  
  var songLength: Int {
    return songPlayer.totalRows
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
  
  var longestStreak: Int {
    return notesPlayedOrMissed.reduce((sum: 0, biggestSum: 0)) {
      if $1 {
        return (sum: $0.sum + 1, biggestSum: max($0.biggestSum, $0.sum + 1))
      } else {
        return (sum: 0, biggestSum: $0.biggestSum)
      }
    }.biggestSum
  }
  
  var multiplier: Int {
    return min(streak / 10 + 1, Game.maxMultiplier)
  }
  
  var health: Double {
    return Double(healthInternal) / Double(Game.maxHealth)
  }
  
  var score = 0
  
  init(songPath: String, speed: Int) {
    self.speed = speed
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
    introRowCount = 15
    for row in 0 ..< introRowCount {
      if notes[row].count > 0 {
        break
      }
      introRowCount -= 1
    }
    
    if introRowCount > 0 {
      // Set volume to 0 until the intro is over
      songPlayer.runOnNextUpdate {
        self.songPlayer.volume = 0
      }
    } else {
      introFinished = true
    }
    
    lastRowChange = NSDate().timeIntervalSince1970
    lastRowId = 0
    songPlayer.startPlaying()
    songPlayer.speed = self.speed
  }
  
  func endGame() {
    guard gameEnded == false else { return }
    songPlayer.stop()
    gameEnded = true
    gameWon = false
  }
  
  func togglePaused() {
    songPlayer.pause()
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
    songPlayer.speed = self.speed
    let newPosition = songPlayer.globalRow - (introFinished ? 0 : introRowCount)
    guard lastRowId != newPosition else { return }
    lastRowId = newPosition
    
    let now = NSDate().timeIntervalSince1970
    lastRowTime = now - lastRowChange
    lastRowChange = now
    let lastRow = Int(position - 1)
    if notes[lastRow].count > 0 && lastRowPlayed != lastRow {
      handleFailedToPlayRow(row: lastRow)
    }
    
    if !introFinished && songPlayer.globalRow >= introRowCount {
      songPlayer.volume = 128
      songPlayer.setPattern(pattern: 0)
      songPlayer.runOnNextUpdate {
        self.introFinished = true
      }
    }
  }
  
  func songPlayerSongEnded(songPlayer: SongPlayer) {
    winGame()
  }
  
  // MARK: Private
  private let songPlayer = SongPlayer()
  private let speed: Int
  private var buttonsDown = Set<Button>()
  private var lastRowChange: TimeInterval = 0
  private var lastRowTime: TimeInterval = 1
  private var lastRowPlayed = -1
  private var notesPlayedOrMissed = [Bool]()
  private var rowsMissed = [Int:Int]()
  private var healthInternal = Int(Float(maxHealth) * 0.75)
  private var introFinished = false
  private var lastRowId = 0
  private var introRowCount = 0
  
  private static let noteHitThreshold = 0.9
  private static let maxHealth = 200
  private static let maxMultiplier = 4
  
  private func loseGame() {
    gameEnded = true
    songPlayer.stop()
    delegate?.gameDidLose(game: self)
  }
  
  private func winGame() {
    if !gameEnded {
      gameEnded = true
      gameWon = true
      delegate?.gameDidWin(game: self)
    }
  }
  
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
    let accuracy = (Double(row) - position) / Game.noteHitThreshold
    delegate?.gameDidPlayRow(game: self, row: row, accuracy: accuracy)
  }
  
  private func checkLoseCondition() {
    if health == 0 {
      loseGame()
    }
  }
}
