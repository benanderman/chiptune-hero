//
//  SongPlayer.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

class SongPlayer {
	var song: UnsafeMutablePointer<MODULE>?
	
	func openSong(path: String) {
		if song != nil {
			Player_Stop()
			Player_Free(song!)
		}
		
		song = Player_Load(path, 128, false)
		guard song != nil else {
			print("Could not load module, reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
			return
		}
	}
	
	func startPlaying() {
		if let module = song {
			Player_Start(module)
			update()
		}
	}
	
	func pause() {
		Player_TogglePause()
	}
	
	func update() {
		if Player_Active() {
			MikMod_Update()
			let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
			dispatch_after(delay, dispatch_get_main_queue(), update)
		}
	}
	
	func queryVoices() {
		if let module = song {
			let voiceInfos = UnsafeMutablePointer<VOICEINFO>(malloc(sizeof(VOICEINFO) * 128))
			Player_QueryVoices(UWORD(module.memory.totalchn), voiceInfos)
			var output = ""
			for i in 0 ..< module.memory.totalchn {
				let voiceInfo = voiceInfos.advancedBy(Int(i)).memory
				if voiceInfo.kick != 0 {
					output += "|\(voiceInfo.period)"
				} else {
					output += "|    "
				}
			}
			print(output)
			free(voiceInfos)
		}
	}
	
	init() {
		
	}
	
	init(song: String) {
		openSong(song)
	}
	
	deinit {
		if let module = song {
			Player_Stop()
			Player_Free(module)
		}
	}
}