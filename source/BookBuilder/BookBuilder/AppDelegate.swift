//
//  AppDelegate.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDefaults.registerApplicationDefaults()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

