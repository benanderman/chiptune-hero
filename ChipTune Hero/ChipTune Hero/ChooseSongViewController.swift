//
//  ChooseSongViewController.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 5/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Foundation
import UIKit

class ChooseSongViewController: UIViewController {
  var songs = [SongInfo]()
  var selectedSong: SongInfo?
  
  override func viewDidLoad() {
    guard let path = Bundle.main.path(forResource: "song_list", ofType: "json") else { fatalError() }
    if let data = FileManager.default.contents(atPath: path) {
      let json = JSON(data: data)
      let songOrder = json["song_order"].arrayValue.map { $0.stringValue }
      let songInfos = json["songs"].dictionaryValue
      self.songs = songOrder.map { SongInfo(json: songInfos[$0]!) }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let gameVC = segue.destination as? GameViewController else { fatalError() }
    gameVC.songInfo = selectedSong
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
    return cell
  }
}
