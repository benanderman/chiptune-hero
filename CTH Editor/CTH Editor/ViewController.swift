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
	@IBOutlet weak var channelChecksContainer: NSView!
	@IBOutlet weak var scrollView: NSScrollView!
	
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
	
	func rebuildPlayerUI () {
		for view in channelChecksContainer.subviews {
			view.removeFromSuperview()
		}
		guard let totalChannels = songPlayer.totalChannels else {
			return
		}
		for i in 0 ..< totalChannels {
			let checkbox = NSButton(frame: NSRect(x: CGFloat(i) * 36, y: 0, width: 18, height: 18))
			checkbox.setButtonType(.SwitchButton)
			checkbox.state = NSOnState
			checkbox.tag = i
			checkbox.target = self
			checkbox.action = Selector("toggleMute:")
			channelChecksContainer.addSubview(checkbox)
		}
	}
	
	func toggleMute(sender: NSButton) {
		let channel = sender.tag
		let mute = sender.state != NSOnState
		songPlayer.setChannelMute(channel, mute: mute)
	}

	@IBAction func loadSong(sender: NSButton) {
		let path = NSBundle.mainBundle().pathForResource(songTextArea.stringValue, ofType: nil)
		songPlayer.openSong(path!)
		rebuildPlayerUI()
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
	
	@IBAction func writeData(sender: NSButton) {
		songPlayer.writeData()
	}
}

