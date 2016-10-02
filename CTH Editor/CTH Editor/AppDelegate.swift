//
//  AppDelegate.swift
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_: Notification) {
    initMikMod()
  }

	func applicationWillTerminate(_: Notification) {
		MikMod_Exit()
	}

	func initMikMod() {
		MikMod_RegisterAllDrivers()
		MikMod_RegisterAllLoaders()
		
		md_mode |= UInt16(DMODE_SOFT_MUSIC)
		
		if (MikMod_Init("") != 0) {
      print("Could not initialize sound, reason: \(String(cString: MikMod_strerror(MikMod_errno)))")
			fatalError()
		}
	}
}

