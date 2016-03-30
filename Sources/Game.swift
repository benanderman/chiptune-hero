//
//  Game.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/29/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

protocol GameDelegate {
  func gameDidPlayRow(game: Game, row: Int)
  func gameDidFailRow(game: Game, row: Int)
}

class Game: SongPlayerDelegate {
  enum Button: Int {
    case One = 1
    case Two
    case Three
    case Four
  }
  
  var delegate: GameDelegate?
  
  var notes: NotesLayer {
    return songPlayer.songSpec?.playable ?? NotesLayer(rows: 0)
  }
  
  var position: Double {
    let elapsed = NSDate().timeIntervalSince1970 - lastRowChange
    return Double(songPlayer.globalRow) + min(1, elapsed / lastRowTime)
  }
  
  init(songPath: String) {
    songPlayer.delegate = self
    songPlayer.openSong(songPath)
  }
  
  func startGame() {
    lastRowChange = NSDate().timeIntervalSince1970
    songPlayer.startPlaying()
  }
  
  func buttonDown(button: Button) {
    buttonsDown.insert(button)
  }
  
  func buttonUp(button: Button) {
    buttonsDown.remove(button)
  }
  
  func songPlayerPositionChanged(songPlayer: SongPlayer) {
    let now = NSDate().timeIntervalSince1970
    lastRowTime = now - lastRowChange
    lastRowChange = now
  }
  
  // MARK: Private
  private var songPlayer = SongPlayer()
  private var buttonsDown = Set<Button>()
  private var lastRowChange: NSTimeInterval = 0
  private var lastRowTime: NSTimeInterval = 1
  private var lastRowPlayed = 0
  
  private func checkIfRowPlayed() {
    let rowId = Int(round(position))
    let row = Set(notes[rowId])
    let buttons = Set(buttonsDown.map { $0.rawValue })
    if lastRowPlayed == rowId {
      handleFailedToPlayRow(rowId)
      return
    }
    if buttons == row {
      handlePlayedRow(rowId)
    } else if row.isSubsetOf(buttons) {
      // The player pressed too many buttons
      handleFailedToPlayRow(rowId)
    }
  }
  
  private func handleFailedToPlayRow(row: Int) {
    songPlayer.playChannels = .Inactive
    delegate?.gameDidFailRow(self, row: row)
  }
  
  private func handlePlayedRow(row: Int) {
    lastRowPlayed = row
    songPlayer.playChannels = .Custom
    for i in 0 ..< (songPlayer.totalChannels ?? 0) {
      songPlayer.setChannelMute(i, mute: false)
    }
    delegate?.gameDidPlayRow(self, row: row)
  }
}
