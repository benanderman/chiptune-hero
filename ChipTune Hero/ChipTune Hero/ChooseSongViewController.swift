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
    guard let path = NSBundle.mainBundle().pathForResource("song_list", ofType: "json") else { fatalError() }
    if let data = NSData(contentsOfFile: path) {
      let json = JSON(data: data)
      let songOrder = json["song_order"].arrayValue.map { $0.stringValue }
      let songInfos = json["songs"].dictionaryValue
      self.songs = songOrder.map { SongInfo(json: songInfos[$0]!) }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let gameVC = segue.destinationViewController as? GameViewController else { fatalError() }
    gameVC.songInfo = selectedSong
  }
}

extension ChooseSongViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedSong = songs[indexPath.row]
    performSegueWithIdentifier("gameVC", sender: self)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

extension ChooseSongViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return songs.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("song", forIndexPath: indexPath)
    guard let songCell = cell as? SongTableViewCell else { fatalError() }
    let songInfo = songs[indexPath.row]
    songCell.titleLabel.text = songInfo.title
    return cell
  }
}
