//
//  MainViewControllerHelper.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation
import Cocoa

class MainViewControllerHelper {
    static func setupBookRootDir(label: NSTextField) {
        label.stringValue = AppDefaults.getBookRootDir()
    }
    
    static func handleRevisedBookRootDir(path: String, userLabel: NSTextField) {
        if (path == "") {
            return
        } else {
            AppDefaults.setBookRootDir(path)
            setupBookRootDir(label: userLabel)
        }
    }
}
