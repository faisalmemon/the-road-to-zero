//
//  AppDefaults.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

class AppDefaults {
    static let bookRootDirKey = "bookRootDir"
    static let bookRootDirKeyDefault = "/"
    
    static func registerApplicationDefaults() {
        let appDefaults = [bookRootDirKey: bookRootDirKeyDefault]
        UserDefaults.standard.register(defaults: appDefaults)
    }
}
