//
//  XMScanner.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 9/18/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

enum XMError: ErrorType {
  case failedToReadFile
  case dataOutOfRange
  case dataRangeMismatch
  case invalidString
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
  let headerLength: Int
  let packingType: Int
  let rowsInPattern: Int
  let patternDataSize: Int
  let notes: [[XMNote]]
}

class XMScanner {
  var path: String
  
  let IDText: String
  let moduleName: String
  let trackerName: String
  let version: Int
  let headerSize: Int
  let songLength: Int
  let restartPosition: Int
  let numberOfChannels: Int
  let numberOfPatterns: Int
  let numberOfInstruments: Int
  let flags: Int
  let defaultTempo: Int
  let defaultBPM: Int
  let patternOrderTable: [Int]
  
  let patterns: [XMPattern]
  
  init (path: String) throws {
    self.path = path
    guard let data = NSFileManager.defaultManager().contentsAtPath(path) else {
      throw XMError.failedToReadFile
    }
    
    do {
      IDText = try XMScanner.getString(data, range: Offset.IDText)
      moduleName = try XMScanner.getString(data, range: Offset.moduleName)
      trackerName = try XMScanner.getString(data, range: Offset.trackerName)
      version = try XMScanner.getWord(data, range: Offset.version)
      headerSize = try XMScanner.getDWord(data, range: Offset.headerSize)
      songLength = try XMScanner.getWord(data, range: Offset.songLength)
      restartPosition = try XMScanner.getWord(data, range: Offset.restartPosition)
      numberOfChannels = try XMScanner.getWord(data, range: Offset.numberOfChannels)
      numberOfPatterns = try XMScanner.getWord(data, range: Offset.numberOfPatterns)
      numberOfInstruments = try XMScanner.getWord(data, range: Offset.numberOfInstruments)
      flags = try XMScanner.getWord(data, range: Offset.flags)
      defaultTempo = try XMScanner.getWord(data, range: Offset.defaultTempo)
      defaultBPM = try XMScanner.getWord(data, range: Offset.defaultBPM)
      patternOrderTable = try XMScanner.getByteArray(data, range: Offset.patternOrderTable)
      
      var patterns = [XMPattern]()
      var offset = Offset.headerSize.location + headerSize
      for _ in 0 ..< numberOfPatterns {
        let (pattern, size) = try XMScanner.getPattern(data, offset: offset, columnCount: numberOfChannels)
        offset += size
        patterns.append(pattern)
      }
      self.patterns = patterns
    }
  }
  
  // MARK: - Getters:
  private static func getChar(data: NSData, range: NSRange, offset: Int = 0) throws -> Int {
    let offsetRange = NSRange(location: range.location + offset, length: range.length)
    guard offsetRange.location + offsetRange.length <= data.length else { throw XMError.dataOutOfRange }
    guard offsetRange.length == 1 else { throw XMError.dataRangeMismatch }
    var byte: UInt8 = 0
    data.getBytes(&byte, range: offsetRange)
    return Int(byte)
  }
  
  private static func getWord(data: NSData, range: NSRange, offset: Int = 0) throws -> Int {
    let offsetRange = NSRange(location: range.location + offset, length: range.length)
    guard offsetRange.location + offsetRange.length <= data.length else { throw XMError.dataOutOfRange }
    guard offsetRange.length == 2 else { throw XMError.dataRangeMismatch }
    var word: UInt16 = 0
    data.getBytes(&word, range: offsetRange)
    return Int(word)
  }
  
  private static func getDWord(data: NSData, range: NSRange, offset: Int = 0) throws -> Int {
    let offsetRange = NSRange(location: range.location + offset, length: range.length)
    guard offsetRange.location + offsetRange.length <= data.length else { throw XMError.dataOutOfRange }
    guard offsetRange.length == 4 else { throw XMError.dataRangeMismatch }
    var dword: UInt32 = 0
    data.getBytes(&dword, range: offsetRange)
    return Int(dword)
  }
  
  private static func getByteArray(data: NSData, range: NSRange, offset: Int = 0) throws -> [Int] {
    let offsetRange = NSRange(location: range.location + offset, length: range.length)
    guard offsetRange.location + offsetRange.length <= data.length else { throw XMError.dataOutOfRange }
    var bytes = [Int8](count: offsetRange.length, repeatedValue: 0)
    data.getBytes(&bytes, range: offsetRange)
    return bytes.map { Int($0) }
  }
  
  private static func getString(data: NSData, range: NSRange, offset: Int = 0) throws -> String {
    let offsetRange = NSRange(location: range.location + offset, length: range.length)
    guard offsetRange.location + offsetRange.length <= data.length else { throw XMError.dataOutOfRange }
    var bytes = [Int8](count: offsetRange.length + 1, repeatedValue: 0)
    data.getBytes(&bytes, range: offsetRange)
    guard let string = String.fromCString(&bytes) else { throw XMError.invalidString }
    return string
  }
  
  private static func getPattern(data: NSData, offset: Int, columnCount: Int) throws -> (XMPattern, Int) {
    do {
      let headerLength = try self.getDWord(data, range: Offset.patternHeaderLength, offset: offset)
      let packingType = try self.getChar(data, range: Offset.packingType, offset: offset)
      let rowsInPattern = try self.getWord(data, range: Offset.rowsInPattern, offset: offset)
      let patternDataSize = try self.getWord(data, range: Offset.patternDataSize, offset: offset)
      
      var notes = [[XMNote]]()
      var noteOffset = 0
      for _ in 0 ..< rowsInPattern {
        var row = [XMNote]()
        for _ in 0 ..< columnCount {
          let (note, noteSize) = try XMScanner.getNote(data, offset:  offset + headerLength + noteOffset)
          row.append(note)
          noteOffset += noteSize
        }
        notes.append(row)
      }
      
      guard patternDataSize == noteOffset else { throw XMError.inconsistentFile }
      
      let pattern = XMPattern(headerLength: headerLength, packingType: packingType, rowsInPattern: rowsInPattern, patternDataSize: patternDataSize, notes: notes)
      return (pattern, headerLength + patternDataSize)
    }
  }
  
  private static func getNote(data: NSData, offset: Int) throws -> (XMNote, Int) {
    var size = 5
    var values = [UInt8](count: 5, repeatedValue: 0)
    values[0] = UInt8(try XMScanner.getChar(data, range: Offset.note, offset: offset))
    if values[0] & 0x80 == 0 {
      values[1] = UInt8(try XMScanner.getChar(data, range: Offset.instrument, offset: offset))
      values[2] = UInt8(try XMScanner.getChar(data, range: Offset.volume, offset: offset))
      values[3] = UInt8(try XMScanner.getChar(data, range: Offset.effectType, offset: offset))
      values[4] = UInt8(try XMScanner.getChar(data, range: Offset.effectParam, offset: offset))
    } else {
      // The note is packed / compressed
      size = 1
      let packSpec = values[0]
      for i in UInt8(0) ..< UInt8(5) {
        if (packSpec >> i) & 1 == 1 {
          values[Int(i)] = UInt8(try XMScanner.getChar(data, range: Offset.note, offset: offset + size))
          size += 1
        }
      }
    }
    return (XMNote(note: values[0], instrument: values[1], volume: values[2], effect: values[3], effectParam: values[4]), size)
  }
}

