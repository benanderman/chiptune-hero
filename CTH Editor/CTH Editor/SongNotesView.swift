//
//  SongNotesView.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/19/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation
import Cocoa

class SongNotesView: NSView {
	
	let rowH = CGFloat(18)
	let colW = CGFloat(36)
	
	var rows = 0
	var columns = 0
	var layers = [NotesLayer]()
	var patternOffsets = [Int]()
  var editingLayer: NotesLayer? {
    didSet {
      setNeedsDisplayInRect(bounds)
    }
  }
  
  var selectedRange: (x1: Int, y1: Int, x2: Int, y2: Int)? {
    guard let start = selectionStart, let end = selectionEnd else { return nil }
    return (x1: min(start.x, end.x), y1: min(start.y, end.y), x2: max(start.x, end.x), y2: max(start.y, end.y))
  }
  
  private var selectionStart: (x: Int, y: Int)?
  private var selectionEnd: (x: Int, y: Int)?
	
	override func drawRect(rect: NSRect) {
		let start = Int((frame.size.height - ceil(rect.origin.y + rect.size.height)) / rowH)
		let end = Int(ceil((frame.size.height - rect.origin.y) / rowH))
		guard start >= 0 && end < rows else { return }
		for i in start ... end {
			for layer in layers {
				drawRow(i, layer: layer)
			}
		}
	}
	
	func drawRow(rowIndex: Int, layer: NotesLayer) {
		let y = frame.size.height - CGFloat(rowIndex + 1) * rowH
		for note in layer[rowIndex] {
			let rect = NSRect(x: CGFloat(note) * colW, y: y, width: colW, height: rowH)
			let path = NSBezierPath(rect: rect)
      var selected = false
      if let sel = selectedRange where layer === editingLayer {
        selected = note >= sel.x1 && note <= sel.x2 && rowIndex >= sel.y1 && rowIndex <= sel.y2
      }
			layer.color.nsColor.colorWithAlphaComponent(0.5).set()
			path.fill()
      NSColor.blackColor().colorWithAlphaComponent(selected ? 1.0 : 0.3).set()
			path.stroke()
		}
		if patternOffsets.contains(rowIndex) {
			let path = NSBezierPath(rect: NSRect(x: 0, y: y, width: frame.size.width, height: rowH))
			NSColor.blueColor().colorWithAlphaComponent(0.3).set()
			path.fill()
		}
	}
	
	func setNoteAtPosition(point: NSPoint, value: Bool) {
		guard let layer = editingLayer else { return }
		
    let (column, row) = positionForPoint(point)
		if layer[row].contains(column) != value {
			if (value) {
				layer.addNote(row: row, column: column)
			} else {
				layer.removeNote(row: row, column: column)
			}
			setNeedsDisplayInRect(bounds)
		}
	}
  
  func positionForPoint(point: NSPoint) -> (x: Int, y: Int) {
    let y = Int((frame.size.height - CGFloat(point.y + 1)) / rowH)
    let x = Int(point.x / colW)
    return (x: x, y: y)
  }
  
  func deselect() {
    selectionStart = nil
    selectionEnd = nil
  }
	
	override func mouseDown(event: NSEvent) {
		let point = convertPoint(event.locationInWindow, fromView: nil)
    if event.modifierFlags.contains(.ShiftKeyMask) {
      if selectionStart == nil {
        selectionStart = positionForPoint(point)
        selectionEnd = selectionStart
      } else {
        selectionEnd = positionForPoint(point)
      }
      setNeedsDisplayInRect(bounds)
    } else {
      if selectedRange != nil {
        deselect()
        setNeedsDisplayInRect(bounds)
        return
      }
      let value = !event.modifierFlags.contains(.AlternateKeyMask)
      setNoteAtPosition(point, value: value)
    }
	}
	
	override func mouseDragged(event: NSEvent) {
		let point = convertPoint(event.locationInWindow, fromView: nil)
    if event.modifierFlags.contains(.ShiftKeyMask) && selectionStart != nil {
      selectionEnd = positionForPoint(point)
      setNeedsDisplayInRect(bounds)
    } else {
      let value = !event.modifierFlags.contains(.AlternateKeyMask)
      setNoteAtPosition(point, value: value)
    }
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	init(layers: [NotesLayer], patternOffsets: [Int], rows: Int, columns: Int) {
		super.init(frame: NSRect(x: 0, y: 0, width: CGFloat(columns) * colW, height: CGFloat(rows) * rowH))
		self.layers = layers
		self.rows = rows
		self.columns = columns
		self.patternOffsets = patternOffsets
	}

	required init?(coder: NSCoder) {
	    super.init(coder: coder)
	}
}
