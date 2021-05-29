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
    public let rootDir: String
    
    public init(root: String, lang: String, output: String) {
        rootDir = root
        language = lang
        outputDir = output
    }
    
    public func getLatexIndexFileURL() -> URL {
        var indexFileURL = URL(fileURLWithPath: outputDir)
        indexFileURL.appendPathComponent("boo.en.idx")
        return indexFileURL
    }
    
    public func getMarkdownFilePath() -> String {
        return rootDir + "/" + "trademarks.md"
    }
}
