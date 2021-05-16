//
//  MainViewControllerHelper.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation
import Cocoa
import BuilderLibrary
import os.log

struct MainViewControllerHelper {
    
    static let log = OSLog(subsystem: "BuilderLibrary", category: "Build")
    static let logger = Logger(log)
    
    static func setupBookRootDir(label: NSTextField) {
        label.stringValue = AppDefaults.getBookRootDir()
    }
    
    static func handleChangeBookRootDir(userLabel: NSTextField) {
        PickBookRootDir.invoke { (path) in
            handleRevisedBookRootDir(
                    path: path,
                    userLabel: userLabel
                )
        }
    }
    
    static func handleRevisedBookRootDir(path: String, userLabel: NSTextField) {
        if (path == "") {
            return
        } else {
            AppDefaults.setBookRootDir(path)
            setupBookRootDir(label: userLabel)
        }
    }
    
    static func handleFindTrademarks() {
        let config = Configuration(root: AppDefaults.getBookRootDir(),
                                   lang: "en",
                                   output: AppDefaults.getOutputDir())
        let library = BuilderLibrary(clientLog: log, configuration: config)

        switch library.updateTrademarkMarkdown() {
        case .TrademarkFileUpdated:
            logger.info("trademark file updated")
            print("trademark file updated")
        case .TrademarkFileSystemFailure:
            print("trademark file update system failure")
        case .TrademarkNotYetIndexed:
            print("trademark file cannot be updated because book not indexed")
        }
    }
    
    static func setupConsole(scrollView: NSScrollView) {
        let task = Process()

        //log stream --style compact --debug --predicate 'subsystem == "BuilderLibrary"'
        task.launchPath = "/usr/bin/log"
        task.arguments = ["stream", "--style", "compact", "--debug", "--predicate",
                          #"subsystem == "BuilderLibrary""#]

        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                print("New output: \(line)")
                //TODO add text to the scroll view
            } else {
                print("Error decoding data: \(pipe.availableData)")
            }
        }

        task.launch()
    }
}
