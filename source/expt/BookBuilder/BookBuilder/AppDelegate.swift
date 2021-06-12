//
//  AppDelegate.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Cocoa
import os.log


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static let log = OSLog(subsystem: "BuilderLibrary", category: "Build")
    static let logger = Logger(log)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

