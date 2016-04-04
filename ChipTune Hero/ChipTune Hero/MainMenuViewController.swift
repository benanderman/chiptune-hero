//
//  MainMenuViewController.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/31/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import UIKit

class MainMenuViewController : UIViewController {
  
  let songNames = ["a_winter_kiss.xm", "_sunlight_.xm"]
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let gameVC = segue.destinationViewController as? GameViewController {
      switch segue.identifier! {
      case "a_winter_kiss":
        gameVC.songName = "a_winter_kiss.xm"
      case "sunlight":
        gameVC.songName = "_sunlight_.xm"
      default:
        break
      }
      
    }
  }
}
