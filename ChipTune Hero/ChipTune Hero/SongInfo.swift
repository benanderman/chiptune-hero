//
//  SongInfo.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 5/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

struct SongInfo {
  let filename: String
  let title: String
  let speedMultiplier: Int
  
  init(json: JSON) {
    guard let filename = json["filename"].string else { fatalError() }
    guard let title = json["title"].string else { fatalError() }
    guard let speedMultiplier = json["speed_multiplier"].int else { fatalError() }
    
    (self.filename, self.title, self.speedMultiplier) = (filename, title, speedMultiplier)
  }
}
