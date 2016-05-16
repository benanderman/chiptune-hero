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
  var patternStarts = [Int]()
  var totalChannels: Int? {
    return song != nil ? Int(song!.memory.numchn) : 0
  }
	
	var globalRow: Int {
		return songSpec?.patternStarts.count > pattern ? songSpec!.patternStarts[pattern] + row : 0
	}
	
	var totalRows: Int {
		return songSpec?.patternStarts.count > 0 ? songSpec!.patternStarts.last! + songSpec!.patterns.last! : 0
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
		song?.memory.loop = false
    dataDelegate?.songPlayerLoadedSong(self)
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