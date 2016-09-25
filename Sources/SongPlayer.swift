//
//  SongPlayer.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

protocol SongPlayerDelegate: class {
  func songPlayerPositionChanged(songPlayer: SongPlayer)
  func songPlayerSongEnded(songPlayer: SongPlayer)
}

protocol SongDataDelegate: SongPlayerDelegate {
  func songPlayerLoadedSong(songPlayer: SongPlayer)
}

enum ChannelSet: Int {
  case Custom = 0
  case Active = 1
  case Inactive = 2
}

class SongPlayer {
  
  weak var delegate: SongPlayerDelegate?
  weak var dataDelegate: SongDataDelegate?
  
  var song: UnsafeMutablePointer<MODULE>?
  var songPath = ""
  private var lastNavigation = NSDate()
  
  // Play position
  var pattern = 0
  var row = 0
  
  var playChannels = ChannelSet.Custom
  var songSpec: SongSpec?
  var patterns = [Int]()
  var patternOrderTable = [Int]()
  var patternStarts = [Int]()
  var totalChannels: Int? {
    return song != nil ? Int(song!.memory.numchn) : 0
  }
  
  var globalRow: Int {
    return patternStarts.count > pattern ? patternStarts[pattern] + row : 0
  }
  
  var totalRows: Int {
    return patternStarts.count > 0 ? patternStarts.last! + patterns[patternOrderTable.last!] : 0
  }
  
  var speed: Int? {
    get {
      guard song != nil else { return nil }
      return Int(song!.memory.sngspd)
    }
    set {
      guard song != nil else { return }
      Player_SetSpeed(newValue == nil ? UWORD(song!.memory.initspeed) : UWORD(newValue!))
    }
  }
  
  var volume: Int? {
    get {
      guard song != nil else { return nil }
      return Int(song!.memory.volume)
    }
    set {
      guard song != nil else { return }
      Player_SetVolume(newValue == nil ? SWORD(song!.memory.initvolume) : SWORD(newValue!))
    }
  }
  
  func nextPosition() {
    lastNavigation = NSDate()
    Player_NextPosition()
  }
  
  func prevPosition() {
    lastNavigation = NSDate()
    if (row < 6) {
      Player_PrevPosition()
    } else {
      // Go to beginning of pattern
      Player_SetPosition(UWORD(pattern))
    }
  }
  
  func openSong(path: String) {
    if song != nil {
      Player_Stop()
      Player_Free(song!)
      pattern = 0
      row = 0
    }
    songPath = path
    
    song = Player_Load(path, 128, false)
    guard song != nil else {
      print("Could not load module, reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
      return
    }
    patterns = (0 ..< song!.memory.numpat).map {
      Int(song!.memory.positions.advancedBy(Int($0)).memory)
    }
    // TODO: Horrible hack — we need to actually look through all the notes for jump "effects"
    // that effectively change the length of patterns. For now, just make A Winter Kiss work.
    if path.rangeOfString("a_winter_kiss.xm") != nil {
      patterns[0x1E] = 21
    }
    do {
      let scanner = try XMScanner(path: path)
      patternOrderTable = scanner.patternOrderTable
      patternStarts = patternOrderTable[0 ..< scanner.songLength - 1].reduce([0], combine: {
        let pattern = patterns[$1]
        return $0 + [$0.last! + pattern]
      })
      dataDelegate?.songPlayerLoadedSong(self)
    } catch is XMError {
      print("Failed to read XM file for a sort of known reason")
    } catch {
      print("Failed to read XM file for an unknown reason")
    }
  }
  
  func getPatternOrderTable(path: String) -> [Int] {
    guard let data = NSFileManager.defaultManager().contentsAtPath(path) else {
      return []
    }
    var length: UInt8 = 0
    data.getBytes(&length, range: NSRange(location: 0x40, length: 1))
    
    var table = [UInt8](count: Int(length), repeatedValue: 0)
    data.getBytes(&table, range: NSRange(location: 0x50, length: Int(length)))
    return table.map { Int($0) }
  }
  
  func startPlaying() {
    if let module = song {
      Player_Start(module)
      autoUpdate()
    }
  }
  
  func pause() {
    Player_TogglePause()
  }
  
  func stop() {
    Player_Stop()
  }
  
  func setChannelMute(channel: Int, mute: Bool) {
    if mute {
      Player_MuteNV(SLONG(channel))
    } else {
      Player_UnmuteNV(SLONG(channel))
    }
  }
  
  func channelIsMuted(channel: Int) -> Bool {
    return Player_Muted(UBYTE(channel))
  }
  
  func autoUpdate() {
    #if GCD_AVAILABLE
      if Player_Active() {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(10_000_000))
        dispatch_after(delay, dispatch_get_main_queue(), autoUpdate)
        update()
      } else {
        songEnded()
      }
    #endif
  }
  
  
  func update() {
    guard Player_Active() else { return }
    MikMod_Update()
    let newPattern = Int(Player_GetOrder())
    let newRow = Int(Player_GetRow())
    guard newPattern != pattern || newRow != row else { return }
    let navigating = NSDate().timeIntervalSinceDate(lastNavigation) < 1
    if !navigating && (newPattern < pattern || (newPattern != pattern + 1 && newRow < row)) {
      songEnded()
      return
    }
    pattern = newPattern
    row = newRow
    delegate?.songPlayerPositionChanged(self)
    dataDelegate?.songPlayerPositionChanged(self)
    updateMutedChannels()
  }
  
  func songEnded() {
    Player_Stop()
    pattern = 0
    row = 0
    delegate?.songPlayerSongEnded(self)
  }
  
  func updateMutedChannels() {
    guard playChannels != .Custom && songSpec != nil else {
      return
    }
    var states = [Bool](count: totalChannels ?? 0, repeatedValue: false)
    for col in songSpec!.activeChannels[globalRow] {
      guard col < states.count else { return }
      states[col] = true
    }
    let active = playChannels == .Active
    for i in 0 ..< states.count {
      setChannelMute(i, mute: active ? !states[i] : states[i])
    }
  }
  
  init() {
    
  }
  
  init(song: String) {
    openSong(song)
    songPath = song
  }
  
  deinit {
    if let module = song {
      Player_Stop()
      Player_Free(module)
    }
  }
}
