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
  
  init(dict: [String:Any]) {
    activeChannels = NotesLayer(dict: dict["activeChannels"] as! [String:Any])
    playable = NotesLayer(dict: dict["playable"] as! [String:Any])
  }
	
#if USE_SWIFTYJSON
	init(json: JSON) {
		activeChannels = NotesLayer(json: json["activeChannels"])
		playable = NotesLayer(json: json["playable"])
	}
#endif
	
#if USE_SWIFTYJSON
	func toJSON() -> JSON {
		return JSON([
			"activeChannels": activeChannels.toJSON(),
			"playable": playable.toJSON()])
	}
#endif
}
