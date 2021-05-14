//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

public struct Configuration {
    public static let en = Configuration(language: "en")
    public static let zh = Configuration(language: "zh")
    
    let language: String
}
