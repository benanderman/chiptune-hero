//
//  main.swift
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/6/16.
//
//

import Foundation
import Glibc

func initMikMod() {
		MikMod_RegisterAllDrivers()
		MikMod_RegisterAllLoaders()
		
		md_mode |= UInt16(DMODE_SOFT_MUSIC)
		
		let result = MikMod_Init("")
		if result != 0 {
      print("Could not initialize sound (\(result)), reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
      fatalError()
		}
}

initMikMod()

let game = Game(songPath: "../songs/a_winter_kiss.xm")
game.startGame()

//let song = Player_Load("../songs/a_winter_kiss.xm", 128, false)
//guard song != nil else {
//  print("Could not load module, reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
//  fatalError()
//}
//Player_Start(song)

setup_gpio()
set_gpio_to_output(4)
set_gpio_to_input(17)
var value = true

while true {
  MikMod_Update()
//  print("Active: \(Player_Active()), \(Player_GetOrder())-\(Player_GetRow())")
  var ts = timespec(tv_sec: 0, tv_nsec: 50_000_000)
  var ret = timespec()
  nanosleep(&ts, &ret)
  
  value = get_gpio_value(17)
  set_gpio_value(4, value)
}

MikMod_Exit()
