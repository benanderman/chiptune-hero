//
//  SongSpec.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/23/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

class SongSpec: Codable {
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
}
