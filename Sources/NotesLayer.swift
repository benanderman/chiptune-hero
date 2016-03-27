//
//  NotesLayer.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/23/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

class NotesLayer {
  struct Color {
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
		self.notes = [[Int]?](count: rows, repeatedValue: nil)
		self.color = color
	}
	
	init(json: JSON) {
		notes = json["notes"].arrayValue.map {
			$0.arrayValue.count != 0 ? $0.arrayValue.map { $0.intValue } : nil
		}
		
		let red = json["color"]["red"].doubleValue
		let green = json["color"]["green"].doubleValue
		let blue = json["color"]["blue"].doubleValue
		let alpha = json["color"]["alpha"].doubleValue
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
	
	func addNote(row row: Int, column: Int) {
		guard row >= 0 && row < notes.count else { return }
		if notes[row] == nil {
			notes[row] = [column]
		} else {
			var cols = notes[row]!
			guard !cols.contains(column) else { return }
			cols.append(column)
			notes[row] = cols.sort()
		}
	}
	
	func removeNote(row row: Int, column: Int) {
		guard row >= 0 && row < notes.count else {
			return
		}
		notes[row] = notes[row]?.filter { $0 != column }
	}
	
	func toJSON() -> JSON {
		let rgba = ["red": color.red, "green": color.green, "blue": color.blue, "alpha": color.alpha]
		let nonOptionalNotes = (0 ..< rows).map { self[$0] }
		let dict: [String:AnyObject] = ["color": rgba, "notes": nonOptionalNotes]
		return JSON(dict)
	}
}
