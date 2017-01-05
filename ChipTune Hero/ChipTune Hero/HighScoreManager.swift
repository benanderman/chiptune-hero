//
//  HighScoreManager.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 11/27/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

struct HighScoreInfo {
  let score: Int
  let maxScore: Int
  let notesHit: Int
  let totalNotes: Int
}

class HighScoreManager {
  static func highestScoreForSong(id: String, difficulty: String) -> HighScoreInfo? {
    let json = getJSON()
    if let highScoreJSON = json[difficulty][id].dictionary {
      let highScore = HighScoreInfo(score: highScoreJSON["score"]?.int ?? 0,
                                    maxScore: highScoreJSON["maxScore"]?.int ?? 1,
                                    notesHit: highScoreJSON["notesHit"]?.int ?? 0,
                                    totalNotes: highScoreJSON["totalNotes"]?.int ?? 1)
      return highScore
    }
    return nil
  }
  
  static func updateHighestScoreForSong(id: String, difficulty: String, highScore: HighScoreInfo) -> Bool {
    let oldHighScore = highestScoreForSong(id: id, difficulty: difficulty)
    if oldHighScore == nil || highScore.score > oldHighScore!.score {
      var json = getJSON()
      if json[difficulty].dictionary == nil {
        json[difficulty] = JSON([:])
      }
      json[difficulty][id] = JSON(["score": highScore.score,
                                   "maxScore": highScore.maxScore,
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
