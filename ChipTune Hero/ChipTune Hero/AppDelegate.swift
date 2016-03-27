//
//  AppDelegate.swift
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/22/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
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

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		initMikMod()
		let path = NSBundle.mainBundle().pathForResource("a_winter_kiss.xm", ofType: nil)
		let song = Player_Load(path!, 128, false)
		guard song != nil else {
			print("Could not load module, reason: \(String.fromCString(MikMod_strerror(MikMod_errno)))")
			return false
		}
		Player_Start(song)
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		MikMod_Exit()
	}


}

