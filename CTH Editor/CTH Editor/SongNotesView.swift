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
	
	var notePositions = [[Int]?]()
	var patternOffsets = [Int]()
	
	override func drawRect(rect: NSRect) {
		let start = Int((frame.size.height - ceil(rect.origin.y + rect.size.height)) / rowH)
		let end = Int(ceil((frame.size.height - rect.origin.y) / rowH))
		guard start >= 0 && end < notePositions.count else { return }
		for i in start ... end {
			let y = frame.size.height - CGFloat(i + 1) * rowH
			if let row = notePositions[i] {
				for note in row {
					let rect = NSRect(x: CGFloat(note) * colW, y: y, width: colW, height: rowH)
					let path = NSBezierPath(rect: rect)
					NSColor.grayColor().set()
					path.fill()
					NSColor.blackColor().colorWithAlphaComponent(0.3).set()
					path.stroke()
				}
			}
			if patternOffsets.contains(i) {
				let path = NSBezierPath(rect: NSRect(x: 0, y: y, width: frame.size.width, height: rowH))
				NSColor.blueColor().colorWithAlphaComponent(0.3).set()
				path.fill()
			}
		}
	}
	
	init(samples: [SongPlayer.SongSample], patternOffsets: [Int], totalRows: Int, totalChannels: Int) {
		self.patternOffsets = patternOffsets
		notePositions = [[Int]?](count: totalRows, repeatedValue: nil)
		super.init(frame: NSRect(x: 0, y: 0, width: CGFloat(totalChannels) * colW, height: CGFloat(totalRows) * rowH))
		for sample in samples {
			let index = patternOffsets[sample.pattern] + sample.row
			notePositions[index] = sample.notes.map { $0.channel }
		}
	}

	required init?(coder: NSCoder) {
	    super.init(coder: coder)
	}
}
