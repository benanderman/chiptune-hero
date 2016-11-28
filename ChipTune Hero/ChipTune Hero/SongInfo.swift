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
  let artist: String
  let speed: Int
  
  init(json: JSON) {
    guard let filename = json["filename"].string else { fatalError() }
    guard let title = json["title"].string else { fatalError() }
    let artist = json["artist"].string ?? ""
    guard let speed = json["speed"].int else { fatalError() }
    
    (self.filename, self.title, self.artist, self.speed) = (filename, title, artist, speed)
  }
}
