//
//  main.swift
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/6/16.
//
//

import Foundation

func initMikMod() {
		MikMod_RegisterAllDrivers()
		MikMod_RegisterAllLoaders()
		
		md_mode |= UInt16(DMODE_SOFT_MUSIC)
		
    md_device = 2
		let result = MikMod_Init("pipe=aplay -f cd")
		if result != 0 {
      print("Could not initialize sound (\(result)), reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
      fatalError()
		}
}

initMikMod()
setup_gpio()

let gm = GameManager(path: "../songs/a_winter_kiss.xm")
gm.run()

MikMod_Exit()
