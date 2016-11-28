//
//  HighScoreManager.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 11/27/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

struct HighScoreInfo {
  var score: Int
  var notesHit: Int
  var totalNotes: Int
}

class HighScoreManager {
  static func highestScoreForSong(id: String) -> HighScoreInfo? {
    let json = getJSON()
    if let highScoreJSON = json[id].dictionary {
      let highScore = HighScoreInfo(score: highScoreJSON["score"]?.intValue ?? 0,
                                    notesHit: highScoreJSON["notesHit"]?.intValue ?? 0,
                                    totalNotes: highScoreJSON["totalNotes"]?.intValue ?? 0)
      return highScore
    }
    return nil
  }
  
  static func updateHighestScoreForSong(id: String, highScore: HighScoreInfo) -> Bool {
    let oldHighScore = highestScoreForSong(id: id)
    if oldHighScore == nil || highScore.score > oldHighScore!.score {
      var json = getJSON()
      json[id] = JSON(["score": highScore.score,
                       "notesHit": highScore.notesHit,
                       "totalNotes": highScore.totalNotes])
      writeJSON(json: json)
      return true
    }
    return false
  }
  
  // MARK: Private
  private static let highScoreFileName = "high_scores.json"
  private static var highScoreFilePath: String {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsPath.path + "/" + highScoreFileName
  }
  
  private static func getJSON() -> JSON {
    if let data = FileManager.default.contents(atPath: highScoreFilePath) {
      return JSON(data: data)
    }
    return JSON([:])
  }
  
  private static func writeJSON(json: JSON) {
    do {
      let data = try json.rawData()
      try data.write(to: URL(fileURLWithPath: highScoreFilePath))
    } catch {
      return
    }
  }
}
