//
//  SongPlayer.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

class SongPlayer {
	
	struct Note {
		let length: Int
		let channel: Int
	}
	
	struct SongSample {
		let notes: [Note]
		let pattern: Int
		let row: Int
	}
	
	var song: UnsafeMutablePointer<MODULE>?
	static var samples = [SongSample]()
	
	func openSong(path: String) {
		if song != nil {
			Player_Stop()
			Player_Free(song!)
			SongPlayer.samples.removeAll()
		}
		
		MikMod_KickCallback = { sngpos, patpos, channels, lengths, len -> Void in
			var notes = [Note]()
			for i in 0 ..< Int(len) {
				let note = Note(length: Int(lengths.advancedBy(i).memory), channel: Int(channels.advancedBy(i).memory))
				notes.append(note)
			}
			let sample = SongSample(notes: notes, pattern: Int(sngpos), row: Int(patpos))
			SongPlayer.samples.append(sample)
		}
		
		song = Player_Load(path, 128, false)
		guard song != nil else {
			print("Could not load module, reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
			return
		}
		song?.memory.wrap = false
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
	
	var lastQuery = -1
	func queryVoices() {
		if let module = song {
			if Player_Active() {
				let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1000000))
				dispatch_after(delay, dispatch_get_main_queue(), queryVoices)
			}
			if Int(Player_GetRow()) == lastQuery {
				return
			}
			lastQuery = Int(Player_GetRow())
			
			let voiceInfos = UnsafeMutablePointer<VOICEINFO>(malloc(sizeof(VOICEINFO) * 128))
			Player_QueryVoices(UWORD(module.memory.totalchn), voiceInfos)
			var output = "\(Player_GetOrder()):\(Player_GetRow()): "
			for i in 0 ..< module.memory.totalchn {
				let voiceInfo = voiceInfos.advancedBy(Int(i)).memory
				let name = voiceInfo.s == nil ? "" : String.fromCString(voiceInfo.s.memory.samplename)!
				let out = "\(voiceInfo.period)-\(name)"
				if voiceInfo.kick != 0 {
					output += "|*\(out)*"
				} else {
					output += "| \(out) "
				}
			}
			print(output)
			free(voiceInfos)
		}
	}
	
	func printData() {
		for sample in SongPlayer.samples {
			var output = "\(sample.pattern)-\(sample.row): "
			var last = 0
			for note in sample.notes {
				for _ in 0 ..< (note.channel - last) {
					output += "| "
				}
				last = note.channel
				output += "|\(note.length)"
			}
			print(output)
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