//
//  XMScanner.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 9/18/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

enum XMError: Error {
  case failedToReadFile
  case dataOutOfRange
  case dataRangeMismatch
  case inconsistentFile
}

private struct Offset {
  // XM header
  static let IDText = NSRange(location: 0, length: 17)
  static let moduleName = NSRange(location: 17, length: 20)
  static let trackerName = NSRange(location: 38, length: 20)
  static let version = NSRange(location: 58, length: 2)
  static let headerSize = NSRange(location: 60, length: 4)
  static let songLength = NSRange(location: 64, length: 2)
  static let restartPosition = NSRange(location: 66, length: 2)
  static let numberOfChannels = NSRange(location: 68, length: 2)
  static let numberOfPatterns = NSRange(location: 70, length: 2)
  static let numberOfInstruments = NSRange(location: 72, length: 2)
  static let flags = NSRange(location: 74, length: 2)
  static let defaultTempo = NSRange(location: 76, length: 2)
  static let defaultBPM = NSRange(location: 78, length: 2)
  static let patternOrderTable = NSRange(location: 80, length: 256)
  
  // Pattern header
  static let patternHeaderLength = NSRange(location: 0, length: 4)
  static let packingType = NSRange(location: 4, length: 1)
  static let rowsInPattern = NSRange(location: 5, length: 2)
  static let patternDataSize = NSRange(location: 7, length: 2)
  
  // Pattern data
  static let note = NSRange(location: 0, length: 1)
  static let instrument = NSRange(location: 1, length: 1)
  static let volume = NSRange(location: 2, length: 1)
  static let effectType = NSRange(location: 3, length: 1)
  static let effectParam = NSRange(location: 4, length: 1)
}

struct XMNote {
  let note: UInt8
  let instrument: UInt8
  let volume: UInt8
  let effect: UInt8
  let effectParam: UInt8
}

struct XMPattern {
  let headerLength: UInt32
  let packingType: UInt8
  let rowsInPattern: UInt16
  let patternDataSize: UInt16
  let notes: [[XMNote]]
}

// This represents an instance of a pattern in the patternOrderTable
struct XMFlatPattern {
  let offset: Int
  let rows: Int
  let patternId: Int
}

class XMScanner {
  var path: String
  
  let IDText: String
  let moduleName: String
  let trackerName: String
  let version: UInt16
  let headerSize: UInt32
  let songLength: UInt16
  let restartPosition: UInt16
  let numberOfChannels: UInt16
  let numberOfPatterns: UInt16
  let numberOfInstruments: UInt16
  let flags: UInt16
  let defaultTempo: UInt16
  let defaultBPM: UInt16
  let patternOrderTable: [UInt8]
  
  let patterns: [XMPattern]
  
  let songStructure: [XMFlatPattern]
  
  init (path: String) throws {
    self.path = path
    guard let data = FileManager.default.contents(atPath: path) else {
      throw XMError.failedToReadFile
    }
    
    do {
      IDText = try XMScanner.getString(data: data, range: Offset.IDText)
      moduleName = try XMScanner.getString(data: data, range: Offset.moduleName)
      trackerName = try XMScanner.getString(data: data, range: Offset.trackerName)
      version = try XMScanner.getWord(data: data, range: Offset.version)
      headerSize = try XMScanner.getDWord(data: data, range: Offset.headerSize)
      songLength = try XMScanner.getWord(data: data, range: Offset.songLength)
      restartPosition = try XMScanner.getWord(data: data, range: Offset.restartPosition)
      numberOfChannels = try XMScanner.getWord(data: data, range: Offset.numberOfChannels)
      numberOfPatterns = try XMScanner.getWord(data: data, range: Offset.numberOfPatterns)
      numberOfInstruments = try XMScanner.getWord(data: data, range: Offset.numberOfInstruments)
      flags = try XMScanner.getWord(data: data, range: Offset.flags)
      defaultTempo = try XMScanner.getWord(data: data, range: Offset.defaultTempo)
      defaultBPM = try XMScanner.getWord(data: data, range: Offset.defaultBPM)
      patternOrderTable = try XMScanner.getByteArray(data: data, range: Offset.patternOrderTable)
      
      var patterns = [XMPattern]()
      var offset = Offset.headerSize.location + Int(headerSize)
      for _ in 0 ..< numberOfPatterns {
        let (pattern, size) = try XMScanner.getPattern(data: data, offset: offset, columnCount: numberOfChannels)
        offset += size
        patterns.append(pattern)
      }
      self.patterns = patterns
      
      songStructure = XMScanner.calculateSongStructure(patterns: patterns, order: patternOrderTable)
    }
  }
  
  // MARK: - Getters:
  private static func getChar(data: Data, range: NSRange, offset: Int = 0) throws -> UInt8 {
    let offsetRange = Range<Data.Index>(uncheckedBounds: (lower: range.location + offset, upper: range.location + offset + range.length))
    guard offsetRange.upperBound <= data.count else { throw XMError.dataOutOfRange }
    guard range.length == 1 else { throw XMError.dataRangeMismatch }
    var byte: UInt8 = 0
    data.copyBytes(to: &byte, from: offsetRange)
    return byte
  }
  
  private static func getWord(data: Data, range: NSRange, offset: Int = 0) throws -> UInt16 {
    let offsetRange = Range<Data.Index>(uncheckedBounds: (lower: range.location + offset, upper: range.location + offset + range.length))
    guard offsetRange.upperBound <= data.count else { throw XMError.dataOutOfRange }
    guard range.length == 2 else { throw XMError.dataRangeMismatch }
    var word: UInt16 = 0
    guard data.copyBytes(to: UnsafeMutableBufferPointer<UInt16>(start: &word, count: 1), from: offsetRange) == 2 else {
      throw XMError.dataRangeMismatch
    }
    return word
  }
  
  private static func getDWord(data: Data, range: NSRange, offset: Int = 0) throws -> UInt32 {
    let offsetRange = Range<Data.Index>(uncheckedBounds: (lower: range.location + offset, upper: range.location + offset + range.length))
    guard offsetRange.upperBound <= data.count else { throw XMError.dataOutOfRange }
    guard range.length == 4 else { throw XMError.dataRangeMismatch }
    var dword: UInt32 = 0
    guard data.copyBytes(to: UnsafeMutableBufferPointer<UInt32>(start: &dword, count: 1), from: offsetRange) == 4 else {
      throw XMError.dataRangeMismatch
    }

    return dword
  }
  
  private static func getByteArray(data: Data, range: NSRange, offset: Int = 0) throws -> [UInt8] {
    let offsetRange = Range<Data.Index>(uncheckedBounds: (lower: range.location + offset, upper: range.location + offset + range.length))
    guard offsetRange.upperBound <= data.count else { throw XMError.dataOutOfRange }
    var bytes = [UInt8](repeating: 0, count: range.length)
    let buffer = UnsafeMutableBufferPointer<UInt8>(start: &bytes[0], count: range.length)
    guard data.copyBytes(to: buffer, from: offsetRange) == range.length else {
      throw XMError.dataRangeMismatch
    }
    return bytes
  }
  
  private static func getString(data: Data, range: NSRange, offset: Int = 0) throws -> String {
    let offsetRange = Range<Data.Index>(uncheckedBounds: (lower: range.location + offset, upper: range.location + offset + range.length))
    guard offsetRange.upperBound <= data.count else { throw XMError.dataOutOfRange }
    var bytes = [UInt8](repeating: 0, count: range.length)
    let buffer = UnsafeMutableBufferPointer<UInt8>(start: &bytes[0], count: range.length)
    guard data.copyBytes(to: buffer, from: offsetRange) == range.length else {
      throw XMError.dataRangeMismatch
    }
    let string = String(cString: &bytes)
    return string
  }
  
  private static func getPattern(data: Data, offset: Int, columnCount: UInt16) throws -> (XMPattern, Int) {
    do {
      let headerLength = try self.getDWord(data: data, range: Offset.patternHeaderLength, offset: offset)
      let packingType = try self.getChar(data: data, range: Offset.packingType, offset: offset)
      let rowsInPattern = try self.getWord(data: data, range: Offset.rowsInPattern, offset: offset)
      let patternDataSize = try self.getWord(data: data, range: Offset.patternDataSize, offset: offset)
      
      var notes = [[XMNote]]()
      var noteOffset: UInt16 = 0
      for _ in 0 ..< rowsInPattern {
        var row = [XMNote]()
        for _ in 0 ..< columnCount {
          let (note, noteSize) = try XMScanner.getNote(data: data, offset: Int(offset) + Int(headerLength) + Int(noteOffset))
          row.append(note)
          noteOffset += UInt16(noteSize)
        }
        notes.append(row)
      }
      
      guard patternDataSize == noteOffset else { throw XMError.inconsistentFile }
      
      let pattern = XMPattern(headerLength: headerLength, packingType: packingType, rowsInPattern: rowsInPattern, patternDataSize: patternDataSize, notes: notes)
      return (pattern, Int(headerLength) + Int(patternDataSize))
    }
  }
  
  private static func getNote(data: Data, offset: Int) throws -> (XMNote, Int) {
    var size = 5
    var values = [UInt8](repeating: 0, count: 5)
    values[0] = UInt8(try XMScanner.getChar(data: data, range: Offset.note, offset: offset))
    if values[0] & 0x80 == 0 {
      values[1] = try XMScanner.getChar(data: data, range: Offset.instrument, offset: offset)
      values[2] = try XMScanner.getChar(data: data, range: Offset.volume, offset: offset)
      values[3] = try XMScanner.getChar(data: data, range: Offset.effectType, offset: offset)
      values[4] = try XMScanner.getChar(data: data, range: Offset.effectParam, offset: offset)
    } else {
      // The note is packed / compressed
      size = 1
      let packSpec = values[0]
      for i in UInt8(0) ..< UInt8(5) {
        if (packSpec >> i) & 1 == 1 {
          values[Int(i)] = UInt8(try XMScanner.getChar(data: data, range: Offset.note, offset: offset + size))
          size += 1
        }
      }
    }
    return (XMNote(note: values[0], instrument: values[1], volume: values[2], effect: values[3], effectParam: values[4]), size)
  }
  
  private static func calculateSongStructure(patterns: [XMPattern], order: [UInt8]) -> [XMFlatPattern] {
    var patternBreaks = [Int?](repeating: nil, count: patterns.count)
    var patternJumps = [(Int, Int)?](repeating: nil, count: patterns.count)
    for (patternIndex, pattern) in patterns.enumerated() {
      _pattern: for (rowIndex, row) in pattern.notes.enumerated() {
        for note in row {
          if note.effect == 0xD {
            patternBreaks[patternIndex] = rowIndex
            break _pattern
          } else if note.effect == 0xB {
            patternJumps[patternIndex] = (rowIndex, Int(note.effectParam))
            break _pattern
          }
        }
      }
    }
    
    var structure = [XMFlatPattern]()
    
    var rowSum = 0
    for patternIndex in order {
      let pattern = patterns[Int(patternIndex)]
      let patternBreak = patternBreaks[Int(patternIndex)]
      let patternJump = patternJumps[Int(patternIndex)]
      var length = Int(pattern.rowsInPattern)
      
      if patternBreak != nil {
        length = patternBreak! + 1
      } else if patternJump != nil {
        length = patternJump!.0 + 1
      }
      
      structure.append(XMFlatPattern(offset: rowSum, rows: length, patternId: Int(patternIndex)))
      
      // If there's a pattern jump, it's probably the end of the song
      if patternJump != nil {
        break
      }
      
      rowSum += length
    }
    
    return structure
  }
}

