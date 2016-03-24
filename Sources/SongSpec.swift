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
	
	init(activeChannels: NotesLayer, playable: NotesLayer) {
		self.activeChannels = activeChannels
		self.playable = playable
	}
	
	init(json: JSON) {
		activeChannels = NotesLayer(json: json["activeChannels"])
		playable = NotesLayer(json: json["playable"])
	}
	
	func toJSON() -> JSON {
		return JSON([
			"activeChannels": activeChannels.toJSON(),
			"playable": playable.toJSON()])
	}
}
