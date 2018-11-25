//
//  HighScoreManager.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 11/27/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation

struct HighScoreInfo: Codable {
  let score: Int
  let maxScore: Int
  let notesHit: Int
  let totalNotes: Int
}

typealias HighScoreCollection = [String: [String: HighScoreInfo]]

class HighScoreManager {
  static func highestScoreForSong(id: String, difficulty: SongSpeed) -> HighScoreInfo? {
    let json = getJSON()
    return json[difficulty.rawValue]?[id]
  }
  
  static func updateHighestScoreForSong(id: String, difficulty: SongSpeed, highScore: HighScoreInfo) -> Bool {
    let oldHighScore = highestScoreForSong(id: id, difficulty: difficulty)
    if oldHighScore == nil || highScore.score > oldHighScore!.score {
      var json = getJSON()
      if json[difficulty.rawValue] == nil {
        json[difficulty.rawValue] = [:]
      }
      json[difficulty.rawValue]?[id] = highScore
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
  
  private static func getJSON() -> HighScoreCollection {
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: highScoreFilePath))
      let decoder = JSONDecoder()
      let json = try decoder.decode(HighScoreCollection.self, from: data)
      return json
    } catch let error {
      debugPrint(error)
      return [:]
    }
  }
  
  private static func writeJSON(json: HighScoreCollection) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(json)
      try data.write(to: URL(fileURLWithPath: highScoreFilePath))
    } catch let error {
      debugPrint(error)
    }
  }
}
