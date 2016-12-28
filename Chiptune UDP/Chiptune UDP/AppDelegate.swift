//
//  AppDelegate.swift
//  Chiptune UDP
//
//  Created by Ben Anderman on 12/28/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var mainView: MainView!
  
  var game: Game?
  
  var oldPosition = 0.0

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    initMikMod()
    
    let path = Bundle.main.path(forResource: "girl_from_mars", ofType: "xm")
    game = Game(songPath: path!, speed: 5)
    game?.delegate = self
    game?.startGame()
    update()
    
    mainView.delegate = self
  }
  
  func update() {
    guard game?.gameEnded == false else { return }
    
    let position = round(game!.position * 2) / 2
    if position != oldPosition {
      let intPos = Int(round(position))
      var cols = [[Bool]]()
      for i in intPos ..< intPos + 9 {
        let row = game!.notes[i].reduce([false, false, false, false]) {
          var result = $0
          result[$1] = true
          return result
        }
        cols.append(row)
        cols.append(row)
      }
      let offset = 1 - (intPos - Int(position))
      cols = [[Bool]](cols[0 + offset ..< cols.count - (2 - offset)])
      setDisplay(cols)
      oldPosition = position
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      self.update()
    }
  }
  
  func setDisplay(_ cols: [[Bool]]) {
    let flattened = cols.reduce([Bool]()) { $1 + $0 }
    var bytes = [UInt8](repeating: 0, count: 8)
    for (i, value) in flattened.enumerated() {
      let intValue = value ? 1 : 0
      bytes[i / 8] = bytes[i / 8] | UInt8(intValue << (7 - i % 8))
    }
    
    var addr = in_addr(s_addr: 0)
    inet_pton(AF_INET, "192.168.2.5", &addr)
    udpSend(bytesToSend: bytes, address: addr, port: 1337)
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
  
  func udpSend(bytesToSend: [UInt8], address: in_addr, port: CUnsignedShort) {
    func htons(value: CUnsignedShort) -> CUnsignedShort {
      return (value << 8) + (value >> 8);
    }
    
    let fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
    
    var addr = sockaddr_in(
      sin_len:    __uint8_t(MemoryLayout<sockaddr_in>.size),
      sin_family: sa_family_t(AF_INET),
      sin_port:   htons(value: port),
      sin_addr:   address,
      sin_zero:   ( 0, 0, 0, 0, 0, 0, 0, 0 )
    )
    
    withUnsafePointer(to: &addr) { ptr -> Void in
      ptr.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr_in>.size) { sockptr -> Void in
        sendto(fd, bytesToSend, bytesToSend.count, 0, sockptr, socklen_t(addr.sin_len))
      }
    }
    
    close(fd)
  }

}

extension AppDelegate: MainViewDelegate {
  func buttonDown(button: Game.Button) {
    game?.buttonDown(button: button)
  }
  
  func buttonUp(button: Game.Button) {
    game?.buttonUp(button: button)
  }
}

extension AppDelegate: GameDelegate {
  func gameDidPlayRow(game: Game, row: Int, accuracy: Double) {
    print("Played row")
  }
  
  func gameDidFailRow(game: Game, row: Int) {
    print("Failed row")
  }
  
  func gameDidLose(game: Game) {
    print("Lost")
  }
  
  func gameDidWin(game: Game) {
    print("Won")
  }
}
