//
//  ChooseSongViewController.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 5/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation
import UIKit

struct SongCollection: Codable {
  let songOrder: [String]
  let songs: [String: SongInfo]
  var songsInOrder: [SongInfo] {
    return songOrder.compactMap {
      return songs[$0]
    }
  }
}

class ChooseSongViewController: UIViewController {
  var songs = [SongInfo]()
  var selectedSong: SongInfo?
  
  let difficulties: [SongSpeed] = [.easy, .hard]
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var difficultySelector: UISegmentedControl!

  var difficulty: SongSpeed {
    return difficulties[difficultySelector.selectedSegmentIndex]
  }
  
  override func viewDidLoad() {
    guard let path = Bundle.main.path(forResource: "song_list", ofType: "json") else { fatalError() }
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      let decoder = JSONDecoder()
      let songCollection = try decoder.decode(SongCollection.self, from: data)
      songs = songCollection.songsInOrder
    } catch let error {
      debugPrint(error)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let gameVC = segue.destination as? GameViewController else { fatalError() }
    gameVC.songInfo = selectedSong
    gameVC.songDifficulty = difficulty
  }
  
  @IBAction func reloadData() {
    tableView.reloadData()
  }
}

extension ChooseSongViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedSong = songs[indexPath.row]
    performSegue(withIdentifier: "gameVC", sender: self)
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
  }
}

extension ChooseSongViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return songs.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "song", for: indexPath as IndexPath)
    guard let songCell = cell as? SongTableViewCell else { fatalError() }
    let songInfo = songs[indexPath.row]
    songCell.titleLabel.text = songInfo.title
    songCell.artistLabel.text = songInfo.artist
    
    if let highScore = HighScoreManager.highestScoreForSong(id: songInfo.filename, difficulty: difficulty) {
      songCell.scoreLabel.text = String(highScore.score)
      let stars = min(Int(round(Float(highScore.score) / Float(highScore.maxScore) * 5)), 5)
      songCell.starsLabel.text = [String](repeating: "★", count: stars).joined()
      songCell.starsLabel.textColor = ["easy": .orange, "hard": .purple][difficulty.rawValue]
    } else {
      songCell.scoreLabel.text = ""
      songCell.starsLabel.text = ""
    }
    return cell
  }
}
