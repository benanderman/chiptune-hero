//
//  SongPlayer.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

extension NotesLayer {
	convenience init(samples: [SongPlayer.SongSample], patternOffsets: [Int], rows: Int) {
		self.init(rows: rows)
		for sample in samples {
			let index = patternOffsets[sample.pattern] + sample.row
			notes[index] = sample.notes.map { $0.channel }
		}
	}
}

protocol SongPlayerDelegate: class {
	func songPlayerPositionChanged(songPlayer: SongPlayer)
}

class SongPlayer {
	
	weak var delegate: SongPlayerDelegate?
	
	struct Note {
		let length: Int
		let channel: Int
	}
	
	struct SongSample {
		let pattern: Int
		let row: Int
		let notes: [Note]
	}
	
	// Because of how MikMod works, and how closures being used as C function pointers work,
	// you can only record this information for one song at a time (but you can also only
	// play one song at a time).
	static var samples = [SongSample]()
	static var patternLengths = [Int]()
	
	var song: UnsafeMutablePointer<MODULE>?
	var songPath = ""
	var samples = [SongSample]()
	var patterns = [Int]()
	var patternStarts = [Int]()
	var totalChannels: Int?
	
	// Play position
	var pattern = 0
	var row = 0
	
	var globalRow: Int {
		return patternStarts.count > 0 ? patternStarts[pattern] + row : 0
	}
	
	var totalRows: Int {
		return patternStarts.count > 0 ? patternStarts.last! + patterns.last! : 0
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
		Player_NextPosition()
	}
	
	func prevPosition() {
		Player_PrevPosition()
	}
	
	func openSong(path: String) {
		if song != nil {
			Player_Stop()
			Player_Free(song!)
			SongPlayer.samples.removeAll()
			SongPlayer.patternLengths.removeAll()
			pattern = 0
			row = 0
		}
		songPath = path
		loadData()
		
		if samples.count == 0 {
			MikMod_KickCallback = { sngpos, patpos, channels, lengths, len -> Void in
				var notes = [Note]()
				for i in 0 ..< Int(len) {
					let note = Note(length: Int(lengths.advancedBy(i).memory), channel: Int(channels.advancedBy(i).memory))
					notes.append(note)
				}
				let sample = SongSample(pattern: Int(sngpos), row: Int(patpos), notes: notes)
				SongPlayer.samples.append(sample)
			}
		}
		
		song = Player_Load(path, 128, false)
		guard song != nil else {
			print("Could not load module, reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
			return
		}
		song?.memory.loop = false
	}
	
	func startPlaying() {
		if let module = song {
			Player_Start(module)
			update()
			updatePlayState()
		}
	}
	
	func pause() {
		Player_TogglePause()
	}
	
	func setChannelMute(channel: Int, mute: Bool) {
		if mute {
			Player_MuteNV(Int32(channel))
		} else {
			Player_UnmuteNV(Int32(channel))
		}
	}
	
	func update() {
		if Player_Active() {
			MikMod_Update()
			let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
			dispatch_after(delay, dispatch_get_main_queue(), update)
		}
	}
	
	func updatePlayState() {
		if Player_Active() {
			let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(10_000_000))
			dispatch_after(delay, dispatch_get_main_queue(), updatePlayState)
		} else {
			return
		}
		let newPattern = Int(Player_GetOrder())
		let newRow = Int(Player_GetRow())
		guard newPattern != pattern || newRow != row else { return }
		if pattern < SongPlayer.patternLengths.count-1 || newPattern < pattern - 1 {
			Player_Stop()
			return
		}
		pattern = newPattern
		row = newRow
		if let del = delegate {
			del.songPlayerPositionChanged(self)
		}
		if patterns.count == 0 {
			updatePatternLengths(pattern, row: row)
		}
	}
	
	func updatePatternLengths(pattern: Int, row: Int) {
		if pattern >= SongPlayer.patternLengths.count {
			SongPlayer.patternLengths.append(0)
		}
		SongPlayer.patternLengths[pattern] = max(row + 1, SongPlayer.patternLengths[pattern])
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
	
	func writeData() {
		let samples = SongPlayer.samples.map {
			[
				"pattern": $0.pattern,
				"row": $0.row,
				"notes": $0.notes.map { ["length": $0.length, "channel": $0.channel] }
			]
		}
		let json = JSON(["samples": samples, "patterns": SongPlayer.patternLengths])
		do {
			let data = try json.rawData()
			data.writeToFile(songPath + ".json", atomically: false)
		} catch {
			return
		}
	}
	
	func loadData() {
		guard let data = NSData(contentsOfFile: songPath + ".json") else {
			return
		}
		let json = JSON(data: data)
		if let patterns = json["patterns"].array {
			self.patterns = patterns.map { $0.intValue }
			var total = 0
			for i in 0 ..< self.patterns.count {
				patternStarts.append(total)
				total += self.patterns[i]
			}
		}
		if let samples = json["samples"].array {
			self.samples = samples.map {
				SongSample(pattern: $0["pattern"].intValue, row: $0["row"].intValue, notes: $0["notes"].arrayValue.map {
						Note(length: $0["length"].intValue, channel: $0["channel"].intValue)
					})
			}
		}
		totalChannels = 0
		for sample in self.samples {
			for note in sample.notes {
				totalChannels = max(note.channel + 1, totalChannels!)
			}
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