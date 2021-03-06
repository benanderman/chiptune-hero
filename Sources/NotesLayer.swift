//
//  NotesLayer.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/23/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

class NotesLayer: Codable {
    struct Color: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
  }
  
  var notes = [[Int]?]()
  var color: Color
  var rows: Int {
    return notes.count
  }
  
  init(rows: Int, color: Color = Color(red: 0, green: 0, blue: 0, alpha: 1)) {
    self.notes = [[Int]?](repeating: nil, count: rows)
    self.color = color
  }
  
  // Gross so that it works on non-Darwin (specifically, Raspberry Pi)
  init(dict: [String:Any]) {
    notes = (dict["notes"] as! [Any]).map {
      let array = $0 as! [Any]
      return array.count != 0 ? array.map { Int($0 as! Double) } : nil
    }
    
    let dictColor = dict["color"] as! [String:Any]
    let red = dictColor["red"] as! Double
    let green = dictColor["green"] as! Double
    let blue = dictColor["blue"] as! Double
    let alpha = dictColor["alpha"] as! Double
    color = Color(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  subscript(index: Int) -> [Int] {
    guard index >= 0 && index < notes.count else { return [] }
    if let row = notes[index] {
      return row
    } else {
      return []
    }
  }
  
  func notesForRange(range: (x1: Int, y1: Int, x2: Int, y2: Int)) -> [[Bool]] {
    return (range.y1 ... range.y2).map { row in
      (range.x1 ... range.x2).map { self[row].contains($0) }
    }
  }
  
  func setNotesAtLocation(notes: [[Bool]], location: (x: Int, y: Int)) {
    for y in 0 ..< notes.count {
      for x in 0 ..< notes[y].count {
        if notes[y][x] {
          addNote(row: location.y + y, column: location.x + x)
        } else {
          removeNote(row: location.y + y, column: location.x + x)
        }
      }
    }
  }
  
  func addNote(row: Int, column: Int) {
    guard row >= 0 && row < notes.count else { return }
    if notes[row] == nil {
      notes[row] = [column]
    } else {
      var cols = notes[row]!
      guard !cols.contains(column) else { return }
      cols.append(column)
      notes[row] = cols.sorted()
    }
  }
  
  func removeNote(row: Int, column: Int) {
    guard row >= 0 && row < notes.count else {
      return
    }
    notes[row] = notes[row]?.filter { $0 != column }
  }
}
