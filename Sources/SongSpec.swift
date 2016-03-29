//
//  SongSpec.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/23/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

class SongSpec {
	var activeChannels: NotesLayer
	var playable: NotesLayer
  var patterns: [Int]
  var patternStarts = [Int]()
	
  init(activeChannels: NotesLayer, playable: NotesLayer, patterns: [Int] = []) {
		self.activeChannels = activeChannels
		self.playable = playable
    self.patterns = patterns
    updatePatternStarts()
	}
	
	init(json: JSON) {
		activeChannels = NotesLayer(json: json["activeChannels"])
		playable = NotesLayer(json: json["playable"])
    patterns = json["patterns"].arrayValue.map { $0.intValue }
    updatePatternStarts()
	}
  
  func updatePatternStarts() {
    patternStarts.removeAll()
    var total = 0
    for i in 0 ..< self.patterns.count {
      patternStarts.append(total)
      total += self.patterns[i]
    }
  }
	
	func toJSON() -> JSON {
		return JSON([
			"activeChannels": activeChannels.toJSON(),
			"playable": playable.toJSON(),
      "patterns": JSON(patterns)])
	}
}
