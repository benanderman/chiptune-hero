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
  var scanner: XMScanner!
  var totalChannels: Int? {
    return song != nil ? Int(song!.pointee.numchn) : 0
  }
  
  var globalRow: Int {
    guard scanner.songStructure.count > pattern else { return 0 }
    return scanner.songStructure[pattern].offset + row
  }
  
  var totalRows: Int {
    guard let flatPattern = scanner.songStructure.last else { return 0 }
    return flatPattern.offset + flatPattern.rows
  }
  
  var speed: Int? {
    get {
      guard song != nil else { return nil }
      return Int(song!.pointee.sngspd)
    }
    set {
      guard song != nil else { return }
      Player_SetSpeed(newValue == nil ? UWORD(song!.pointee.initspeed) : UWORD(newValue!))
    }
  }
  
  var volume: Int? {
    get {
      guard song != nil else { return nil }
      return Int(song!.pointee.volume)
    }
    set {
      guard song != nil else { return }
      Player_SetVolume(newValue == nil ? SWORD(song!.pointee.initvolume) : SWORD(newValue!))
    }
  }
  
  var isPlaying: Bool {
    return Player_Active()
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
      print("Could not load module, reason: \(String(cString: MikMod_strerror(MikMod_errno)))")
      return
    }
    do {
      scanner = try XMScanner(path: path)
      dataDelegate?.songPlayerLoadedSong(songPlayer: self)
    } catch is XMError {
      print("Failed to read XM file for a sort of known reason")
    } catch {
      print("Failed to read XM file for an unknown reason")
    }
  }
  
  func startPlaying() {
    if let module = song {
      Player_Start(module)
      Player_SetPosition(0)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          self.autoUpdate()
        }
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
    let navigating = NSDate().timeIntervalSince(lastNavigation as Date) < 1
    if !navigating && (newPattern < pattern || (newPattern != pattern + 1 && newRow < row)) {
      songEnded()
      return
    }
    pattern = newPattern
    row = newRow
    delegate?.songPlayerPositionChanged(songPlayer: self)
    dataDelegate?.songPlayerPositionChanged(songPlayer: self)
    updateMutedChannels()
  }
  
  func songEnded() {
    Player_Stop()
    pattern = 0
    row = 0
    delegate?.songPlayerSongEnded(songPlayer: self)
  }
  
  func updateMutedChannels() {
    guard playChannels != .Custom && songSpec != nil else {
      return
    }
    var states = [Bool](repeating: false, count: totalChannels ?? 0)
    for col in songSpec!.activeChannels[globalRow] {
      guard col < states.count else { return }
      states[col] = true
    }
    let active = playChannels == .Active
    for i in 0 ..< states.count {
      setChannelMute(channel: i, mute: active ? !states[i] : states[i])
    }
  }
  
  init() {
    
  }
  
  init(song: String) {
    openSong(path: song)
    songPath = song
  }
  
  deinit {
    if let module = song {
      Player_Stop()
      Player_Free(module)
    }
  }
}
