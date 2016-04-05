//
//  SongInfoManager.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/28/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

extension NotesLayer {
  convenience init(samples: [SongInfoManager.SongSample], patternOffsets: [Int], rows: Int) {
    self.init(rows: rows)
    for sample in samples {
      let index = patternOffsets[sample.pattern] + sample.row
      notes[index] = sample.notes.map { $0.channel }
    }
  }
}

class SongInfoManager: SongDataDelegate {
  
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
  
  var samples = [SongSample]()
  var patterns = [Int]()
  var patternStarts = [Int]()
  var totalChannels: Int?
  
  var songPath = ""
  
  var totalRows: Int {
    return patternStarts.count > 0 ? patternStarts.last! + patterns.last! : 0
  }
  
  func songPlayerLoadedSong(songPlayer: SongPlayer) {
    songPath = songPlayer.songPath
    SongInfoManager.samples.removeAll()
    SongInfoManager.patternLengths.removeAll()
    totalChannels = nil
    loadData()
    
    if samples.count == 0 {
      MikMod_KickCallback = { sngpos, patpos, channels, lengths, len in
        var notes = [Note]()
        for i in 0 ..< Int(len) {
          let note = Note(length: Int(lengths.advancedBy(i).memory), channel: Int(channels.advancedBy(i).memory))
          notes.append(note)
        }
        let sample = SongSample(pattern: Int(sngpos), row: Int(patpos), notes: notes)
        SongInfoManager.samples.append(sample)
      }
    }
  }
  
  func songPlayerSongEnded(songPlayer: SongPlayer) {
    
  }
  
  func updatePatternLengths(pattern: Int, row: Int) {
    if pattern >= SongInfoManager.patternLengths.count {
      SongInfoManager.patternLengths.append(0)
    }
    SongInfoManager.patternLengths[pattern] = max(row + 1, SongInfoManager.patternLengths[pattern])
  }
  
  func songPlayerPositionChanged(songPlayer: SongPlayer) {
    if samples.count == 0 {
      updatePatternLengths(songPlayer.pattern, row: songPlayer.row)
    }
  }
  
  func printData() {
    for sample in SongInfoManager.samples {
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
    let samples = SongInfoManager.samples.map {
      [
        "pattern": $0.pattern,
        "row": $0.row,
        "notes": $0.notes.map { ["length": $0.length, "channel": $0.channel] }
      ]
    }
    let json = JSON(["samples": samples, "patterns": SongInfoManager.patternLengths])
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
      patternStarts = []
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
}
