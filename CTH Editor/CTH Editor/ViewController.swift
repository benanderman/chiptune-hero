//
//  ViewController.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, SongPlayerDelegate {
	
	@IBOutlet weak var channelChecksContainer: NSView!
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var speedSlider: NSSlider!
	@IBOutlet weak var volumeSlider: NSSlider!
  @IBOutlet weak var editingLayerPopUp: NSPopUpButton!
  @IBOutlet weak var infoExtractionMessage: NSTextField!
	
	var playHead: NSBox?
	var notesView: SongNotesView?
  var scrollOnNextRow = false
	
	let songPlayer = SongPlayer()
  let songInfoManager = SongInfoManager()
	var songSpec: SongSpec?
  
  var copiedNotes: [[Bool]]?

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear() {
		
	}

	override var representedObject: AnyObject? {
		didSet {
			
		}
  }
  
  func openDocument(sender: AnyObject) {
    let openPanel = NSOpenPanel.init()
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    openPanel.allowsMultipleSelection = false
    openPanel.beginSheetModalForWindow(NSApp.mainWindow!, completionHandler: { (result: Int) in
      if result == NSFileHandlingPanelOKButton {
        let url = openPanel.URLs.first!
        self.loadSongWithPath(url.path!)
      }
    });
  }
  
  func copy(sender: AnyObject) {
    if let range = notesView?.selectedRange {
      copiedNotes = notesView?.editingLayer?.notesForRange(range)
    }
  }
  
  func paste(sender: AnyObject) {
    guard let window = self.view.window else { return }
    guard let notes = self.copiedNotes else { return }
    if let point = self.notesView?.convertPoint(window.mouseLocationOutsideOfEventStream, fromView: nil) {
      guard let location = self.notesView?.positionForPoint(point) else { return }
      notesView?.editingLayer?.setNotesAtLocation(notes, location: location)
      notesView?.setNeedsDisplayInRect(notesView!.bounds)
    }
  }
	
	func rebuildPlayerUI () {
		for view in channelChecksContainer.subviews {
			view.removeFromSuperview()
		}
    self.view.addSubview(infoExtractionMessage)
    scrollView.documentView = nil
    playHead = nil
		guard let totalChannels = songInfoManager.totalChannels else {
			return
		}
    guard songInfoManager.samples.count > 0 && songSpec != nil else {
      return
    }
    self.view.addSubview(infoExtractionMessage, positioned: .Below, relativeTo: scrollView)
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
		
		let songLayer = NotesLayer(samples: songInfoManager.samples, patternOffsets: songPlayer.patternStarts, rows: songPlayer.totalRows)
		let layers = [songLayer, songSpec!.activeChannels, songSpec!.playable]
		notesView = SongNotesView(layers: layers, patternOffsets: songPlayer.patternStarts, rows: songPlayer.totalRows, columns: totalChannels)
		notesView!.editingLayer = songSpec!.activeChannels
		view.addSubview(notesView!)
		
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
    
    updateEditingLayer(editingLayerPopUp)
	}
	
	func songPlayerPositionChanged(songPlayer: SongPlayer) {
		guard playHead != nil else { return }
		playHead?.frame.origin.y = CGFloat(songPlayer.totalRows - songPlayer.globalRow - 1) * 18
    if scrollOnNextRow {
      scrollToPlayHead()
      scrollOnNextRow = false
    }
		for i in 0 ..< songInfoManager.totalChannels! {
			let checkbox = channelChecksContainer.subviews[i] as! NSButton
			checkbox.state = songPlayer.channelIsMuted(i) ? NSOffState : NSOnState
		}
	}
  
  func songPlayerSongEnded(songPlayer: SongPlayer) {
    guard playHead == nil else { return }
    // If there's no playhead, then we must not have song data yet,
    // so we should save our song data, then reload the song.
    songInfoManager.writeData()
    loadSongWithPath(songPlayer.songPath)
  }
  
  func scrollToPlayHead() {
    guard playHead != nil else { return }
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
  
  func loadSongWithPath(path: String) {
    songPlayer.delegate = self
    songPlayer.dataDelegate = songInfoManager
    songPlayer.openSong(path)
    songSpec = nil
    let specPath = path + ".spec.json"
    if let data = NSData(contentsOfFile: specPath) {
      let json = JSON(data: data)
      songSpec = SongSpec(json: json)
    }
    if songSpec == nil && songInfoManager.samples.count > 0 {
      let activeChannels = NotesLayer(rows: songPlayer.totalRows, color: .init(nsColor: NSColor.redColor()))
      let playable = NotesLayer(rows: songPlayer.totalRows, color: .init(nsColor: NSColor.yellowColor()))
      songSpec = SongSpec(activeChannels: activeChannels, playable: playable)
    }
    songPlayer.songSpec = songSpec
    
    rebuildPlayerUI()
  }
	
	@IBAction func updateSpeed(sender: NSSlider) {
		songPlayer.speed = Int(round(sender.doubleValue))
		sender.integerValue = songPlayer.speed ?? 1
	}
	
	@IBAction func updateVolume(sender: NSSlider) {
		songPlayer.volume = sender.integerValue
	}
	
	@IBAction func playSong(sender: NSButton) {
    songPlayer.startPlaying()
    scrollOnNextRow = true
	}
	
	@IBAction func pauseSong(sender: NSButton) {
		songPlayer.pause()
	}
	
	@IBAction func nextPosition(sender: AnyObject) {
    songPlayer.nextPosition()
    scrollOnNextRow = true
	}
	
	@IBAction func prevPosition(sender: AnyObject) {
		songPlayer.prevPosition()
    scrollOnNextRow = true
	}
	
	@IBAction func printData(sender: NSButton) {
		songInfoManager.printData()
	}
	
	@IBAction func writeData(sender: NSButton) {
		songInfoManager.writeData()
	}
	
	@IBAction func writeSongSpec(sender: AnyObject) {
		if let data = try? songSpec?.toJSON().rawData() {
			data?.writeToFile(songPlayer.songPath + ".spec.json", atomically: false)
		}
	}
	
	@IBAction func updateSelectedChannels(sender: NSPopUpButton) {
		songPlayer.playChannels = ChannelSet(rawValue: sender.selectedTag()) ?? .Custom
	}
	
	@IBAction func updateEditingLayer(sender: NSPopUpButton) {
		let layer = sender.selectedTag() == 0 ? songSpec?.activeChannels : songSpec?.playable
		notesView?.editingLayer = layer
	}
}

