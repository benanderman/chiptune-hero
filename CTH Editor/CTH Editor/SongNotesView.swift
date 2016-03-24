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
	var editingLayer: NotesLayer?
	
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
			layer.color.colorWithAlphaComponent(0.5).set()
			path.fill()
			NSColor.blackColor().colorWithAlphaComponent(0.3).set()
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
		
		let row = Int((frame.size.height - CGFloat(point.y + 1)) / rowH)
		let column = Int(point.x / colW)
		if layer[row].contains(column) != value {
			if (value) {
				layer.addNote(row: row, column: column)
			} else {
				layer.removeNote(row: row, column: column)
			}
			setNeedsDisplayInRect(bounds)
		}
	}
	
	override func mouseDown(event: NSEvent) {
		let point = convertPoint(event.locationInWindow, fromView: nil)
		let value = !event.modifierFlags.contains(.AlternateKeyMask)
		setNoteAtPosition(point, value: value)
	}
	
	override func mouseDragged(event: NSEvent) {
		let point = convertPoint(event.locationInWindow, fromView: nil)
		let value = !event.modifierFlags.contains(.AlternateKeyMask)
		setNoteAtPosition(point, value: value)
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
