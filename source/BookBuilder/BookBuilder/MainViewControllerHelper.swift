//
//  MainViewControllerHelper.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation
import Cocoa
import BuilderLibrary

struct MainViewControllerHelper {
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
        let config = Configuration(lang: "en", output: AppDefaults.getOutputDir())
        let result = Trademarks.findTrademarks(config: config)
        print(result)
    }
}
