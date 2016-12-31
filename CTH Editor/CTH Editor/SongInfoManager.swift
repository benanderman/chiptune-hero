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
      guard sample.pattern < patternOffsets.count else { continue }
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
  
  var samples = [SongSample]()
  var totalChannels: Int?
  
  var songPath = ""
  
  func songPlayerLoadedSong(songPlayer: SongPlayer) {
    songPath = songPlayer.songPath
    SongInfoManager.samples.removeAll()
    totalChannels = nil
    
    loadData()
//    printData()
//    print("------------------------")
//    loadDataWithScanner()
//    printData()
    
    if samples.count == 0 {
      MikMod_KickCallback = { sngpos, patpos, channels, lengths, len in
        var notes = [Note]()
        for i in 0 ..< Int(len) {
          let note = Note(length: Int(lengths!.advanced(by: i).pointee), channel: Int(channels!.advanced(by: i).pointee))
          notes.append(note)
        }
        let sample = SongSample(pattern: Int(sngpos), row: Int(patpos), notes: notes)
        SongInfoManager.samples.append(sample)
      }
    }
  }
  
  func songPlayerSongEnded(songPlayer: SongPlayer) {
    
  }
  
  func songPlayerPositionChanged(songPlayer: SongPlayer) {
    
  }
  
  func printData() {
    for sample in samples {
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
    let json = JSON(["samples": samples])
    do {
      let data = try json.rawData()
      if let path = songInfoPathForSong(path: songPath) {
        try data.write(to: URL(fileURLWithPath: path))
      }
    } catch {
      return
    }
  }
  
  func loadDataWithScanner() {
    guard let scanner = try? XMScanner(path: songPath) else { return }
    
    samples.removeAll()
    for patternIndex in 0 ..< scanner.numberOfPatterns {
      let pattern = scanner.patterns[Int(patternIndex)]
      for (rowIndex, row) in pattern.notes.enumerated() {
        var notes = [Note]()
        for (channelIndex, note) in row.enumerated() {
          if note.note != 0 {
            notes.append(Note(length: 1, channel: channelIndex))
          }
        }
        if notes.count > 0 {
          let sample = SongSample(pattern: Int(patternIndex), row: rowIndex, notes: notes)
          samples.append(sample)
        }
      }
    }
    
    totalChannels = 0
    for sample in self.samples {
      for note in sample.notes {
        totalChannels = max(note.channel + 1, totalChannels!)
      }
    }
  }
  
  func loadData() {
    guard let path = songInfoPathForSong(path: songPath) else {
      return
    }
    guard let data = FileManager.default.contents(atPath: path) else {
      return
    }
    let json = JSON(data: data)
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
  
  func songInfoPathForSong(path: String) -> String? {
    guard let data = NSData(contentsOfFile: path) else {
      return nil
    }
    
    let cachesDirectories = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    let cacheDirectory = cachesDirectories.first!.appendingPathComponent("\(Bundle.main.bundleIdentifier!)")
    try! FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    return NSURL(string: "\(data.hash).json", relativeTo: cacheDirectory)?.path
  }
}
