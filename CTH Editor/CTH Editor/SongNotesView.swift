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
	
	let rowHeight = CGFloat(18)
	let colWidth = CGFloat(36)
	
	var notePositions = [[Int]?]()
	
	override func drawRect(rect: NSRect) {
		let start = Int((frame.size.height - ceil(rect.origin.y + rect.size.height)) / rowHeight)
		let end = Int((frame.size.height - rect.origin.y) / rowHeight)
		guard start >= 0 && end < notePositions.count else { return }
		for i in start ... end {
			if let row = notePositions[i] {
				for note in row {
					let y = frame.size.height - CGFloat(i) * 18
					let rect = NSRect(x: CGFloat(note) * 36, y: y, width: 36, height: 18)
					let path:NSBezierPath = NSBezierPath(rect: rect)
					NSColor.grayColor().set()
					path.fill()
					NSColor.blackColor().colorWithAlphaComponent(0.3).set()
					path.stroke()
				}
			}
		}
	}
	
	init(samples: [SongPlayer.SongSample], patternOffsets: [Int], totalRows: Int, totalChannels: Int) {
		notePositions = [[Int]?](count: totalRows, repeatedValue: nil)
		super.init(frame: NSRect(x: 0, y: 0, width: CGFloat(totalChannels) * colWidth, height: CGFloat(totalRows) * rowHeight))
		for sample in samples {
			let index = patternOffsets[sample.pattern] + sample.row
			notePositions[index] = sample.notes.map { $0.channel }
		}
	}

	required init?(coder: NSCoder) {
	    super.init(coder: coder)
	}
}
