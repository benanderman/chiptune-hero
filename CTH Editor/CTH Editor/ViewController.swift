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
	@IBOutlet weak var speedSlider: NSSlider!
	@IBOutlet weak var volumeSlider: NSSlider!
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
			checkbox.action = #selector(ViewController.toggleMute(_:))
			channelChecksContainer.addSubview(checkbox)
		}
		
		let view = NSView(frame: NSRect(x: 0, y: 0, width: CGFloat(totalChannels) * 36, height: CGFloat(songPlayer.totalRows * 18)))
		let songLayer = NotesLayer(samples: songPlayer.samples, patternOffsets: songPlayer.patternStarts, rows: songPlayer.totalRows)
		let activeChannelsLayer = NotesLayer(rows: songLayer.rows, color: NSColor.redColor())
		let layers = [songLayer, activeChannelsLayer]
		let channels = songPlayer.totalChannels ?? 0
		let notesView = SongNotesView(layers: layers, patternOffsets: songPlayer.patternStarts, rows: songPlayer.totalRows, columns: channels)
		notesView.editingLayer = activeChannelsLayer
		view.addSubview(notesView)
		
		playHead = NSBox(frame: NSRect(x: 0, y: view.frame.size.height - 18, width: CGFloat(totalChannels) * 36, height: 18))
		playHead?.fillColor = NSColor.greenColor().colorWithAlphaComponent(0.4)
		playHead?.boxType = .Custom
		view.addSubview(playHead!)
		
		scrollView.documentView = view
		scrollView.contentView.scrollToPoint(NSPoint(x: 0, y: view.frame.size.height - scrollView.frame.size.height))
		scrollView.reflectScrolledClipView(scrollView.contentView)
		
		speedSlider.maxValue = Double((songPlayer.speed ?? 1) * 4)
		speedSlider.numberOfTickMarks = Int(speedSlider.maxValue)
		speedSlider.integerValue = songPlayer.speed ?? 1
		volumeSlider.integerValue = songPlayer.volume ?? 128
	}
	
	func songPlayerPositionChanged(songPlayer: SongPlayer) {
		guard playHead != nil else { return }
		playHead?.frame.origin.y = CGFloat(songPlayer.totalRows - songPlayer.globalRow - 1) * 18
		if !scrollView.contentView.documentVisibleRect.contains(playHead!.frame) {
			scrollView.contentView.scrollToPoint(NSPoint(x: 0, y: playHead!.frame.maxY - scrollView.frame.size.height))
			scrollView.reflectScrolledClipView(scrollView.contentView)
		}
	}
	
	func toggleMute(sender: NSButton) {
		let channel = sender.tag
		let mute = sender.state != NSOnState
		songPlayer.setChannelMute(channel, mute: mute)
	}
	
	@IBAction func updateSpeed(sender: NSSlider) {
		songPlayer.speed = Int(round(sender.doubleValue))
		sender.integerValue = songPlayer.speed ?? 1
	}
	
	@IBAction func updateVolume(sender: NSSlider) {
		songPlayer.volume = sender.integerValue
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
	
	@IBAction func nextPosition(sender: AnyObject) {
		songPlayer.nextPosition()
	}
	
	@IBAction func prevPosition(sender: AnyObject) {
		songPlayer.prevPosition()
	}
	
	@IBAction func printData(sender: NSButton) {
		songPlayer.printData()
	}
	
	@IBAction func writeData(sender: NSButton) {
		songPlayer.writeData()
	}
}

