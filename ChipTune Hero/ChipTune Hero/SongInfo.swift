//
//  SongInfo.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 5/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

enum SongSpeed: String, Codable, CaseIterable {
  case hard
  case easy
}

struct SongInfo: Codable {
  let filename: String
  let title: String
  let artist: String?
  let speeds: [String: Int]
  
  func speedValue(for speed: SongSpeed) -> Int? {
    return speeds[speed.rawValue]
  }
}
