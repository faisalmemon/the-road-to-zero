//
//  PickBookRootDir.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation
import Cocoa

struct PickBookRootDir {
    static func invoke(callback: (String) -> Void) {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose top level directory of book"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories    = true
        dialog.canChooseFiles          = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                let path: String = result!.path
                callback(path)
            }
            
        } else {
            // User clicked on "Cancel"
            callback("")
            return
        }
    }
}
