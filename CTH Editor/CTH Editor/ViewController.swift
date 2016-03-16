//
//  ViewController.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet weak var songTextArea: NSTextField!
	
	let songPlayer = SongPlayer()

	override func viewDidLoad() {
		super.viewDidLoad()

	}
	
	override func viewWillAppear() {
		
	}

	override var representedObject: AnyObject? {
		didSet {
			
		}
	}

	@IBAction func loadSong(sender: NSButton) {
		let path = NSBundle.mainBundle().pathForResource(songTextArea.stringValue, ofType: nil)
		songPlayer.openSong(path!)
	}
	
	@IBAction func playSong(sender: NSButton) {
		songPlayer.startPlaying()
	}
	
	@IBAction func pauseSong(sender: NSButton) {
		songPlayer.pause()
	}
	
	@IBAction func printData(sender: NSButton) {
		songPlayer.printData()
	}
}

