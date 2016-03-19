//
//  ViewController.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, SongPlayerDelegate {
	
	@IBOutlet weak var songTextArea: NSTextField!
	@IBOutlet weak var channelChecksContainer: NSView!
	@IBOutlet weak var scrollView: NSScrollView!
	var playHead: NSBox?
	
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
		let view = NSView(frame: NSRect(x: 0, y: 0, width: CGFloat(totalChannels) * 36, height: CGFloat(songPlayer.totalRows * 18)))
		for sample in songPlayer.samples {
			for note in sample.notes {
				let y = view.frame.size.height - CGFloat(songPlayer.patternStarts[sample.pattern] + sample.row + 1) * 18
				let box = NSBox(frame: NSRect(x: CGFloat(note.channel) * 36, y: y, width: 36, height: 18))
				box.fillColor = NSColor.grayColor()
				box.boxType = .Custom
				view.addSubview(box)
			}
		}
		playHead = NSBox(frame: NSRect(x: 0, y: view.frame.size.height - 18, width: CGFloat(totalChannels) * 36, height: 18))
		playHead!.fillColor = NSColor.greenColor().colorWithAlphaComponent(0.4)
		playHead!.boxType = .Custom
		view.addSubview(playHead!)
		scrollView.documentView = view
		scrollView.contentView.scrollToPoint(NSPoint())
	}
	
	func songPlayerPositionChanged(songPlayer: SongPlayer) {
		guard playHead != nil else { return }
		playHead?.frame.origin.y = CGFloat(songPlayer.totalRows - songPlayer.globalRow) * 18
		scrollView.contentView.scrollToPoint(NSPoint(x: 0, y: playHead!.frame.origin.y - scrollView.frame.size.height / 2))
	}
	
	func toggleMute(sender: NSButton) {
		let channel = sender.tag
		let mute = sender.state != NSOnState
		songPlayer.setChannelMute(channel, mute: mute)
	}

	@IBAction func loadSong(sender: NSButton) {
		let path = NSBundle.mainBundle().pathForResource(songTextArea.stringValue, ofType: nil)
		songPlayer.openSong(path!)
		songPlayer.delegate = self
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

