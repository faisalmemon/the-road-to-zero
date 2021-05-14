//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

public struct Configuration {    
    public let language: String
    public let outputDir: String
    
    public init(lang: String, output: String) {
        language = lang
        outputDir = output
    }
}
