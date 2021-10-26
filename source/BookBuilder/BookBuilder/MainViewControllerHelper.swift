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
        case .TrademarkFileSystemFailure:
            logger.info("trademark file update system failure")
        case .TrademarkNotYetIndexed:
            logger.info("trademark file cannot be updated because book not indexed")
        }
    }
    
    static func setupConsole(textView: NSTextView) {
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
                DispatchQueue.main.async {
                    textView.textStorage?.append(NSAttributedString(string: line))
                    textView.scrollToEndOfDocument(self)
                }
            } else {
                logger.error("Error decoding data: \(pipe.availableData)")
            }
        }

        task.launch()
    }
    
    static func buildBookEn() {
        let config = Configuration(root: AppDefaults.getBookRootDir(),
                                   lang: "en",
                                   output: AppDefaults.getOutputDir())
        let library = BuilderLibrary(clientLog: log, configuration: config)

        switch library.buildBook() {
        case .BookBuiltSuccessfully:
            logger.info("book built successfully")
        case .BookBuildFailure:
            logger.error("book build failure")
        }
    }
    
    static func buildBookAllLanguages() {
        for languageIterator in ["en", "zh"] {
            let config = Configuration(root: AppDefaults.getBookRootDir(),
                                       lang: languageIterator,
                                       output: AppDefaults.getOutputDir())
            let library = BuilderLibrary(clientLog: log, configuration: config)
            switch library.buildBook() {
            case .BookBuiltSuccessfully:
                logger.info("\(languageIterator) book built successfully")
            case .BookBuildFailure:
                logger.error("\(languageIterator) book build failure")
                return
            }
        }
    }
}
