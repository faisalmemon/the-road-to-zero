//
//  AppDefaults.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

struct AppDefaults {
    static let bookRootDirKey = "bookRootDir"
    static let bookRootDirKeyDefault = "/"
    
    static func registerApplicationDefaults() {
        let appDefaults = [bookRootDirKey: bookRootDirKeyDefault]
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    static func getBookRootDir() -> String {
        let defaults = UserDefaults.standard
        return defaults.value(forKey: bookRootDirKey) as? String ?? bookRootDirKeyDefault
    }
    
    static func setBookRootDir(_ root: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(root, forKey: bookRootDirKey)
    }
}
