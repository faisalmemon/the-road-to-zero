//
//  Common.swift
//  
//
//  Created by Faisal Memon on 27/10/2021.
//

import Foundation

struct Common {
    static func getContentsOfFile(path: String, throwAwayEmptyLines: Bool = true) throws -> [String]  {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let strings = data.components(separatedBy: .newlines)
        if throwAwayEmptyLines {
            let withoutEmptyLines = strings.filter { $0.count > 1 }
            return withoutEmptyLines
        } else {
            return strings
        }
    }
    
    static func filesToProcess(config: Configuration, bookType: BookType) throws -> [String] {
        
        let sourceFileList: [String]
        
        if bookType == .MarkdownBased {
            sourceFileList = ["frontPages.txt", "mainPages.txt"]
        } else if bookType == .LatexBased {
            sourceFileList = ["frontPages_latex.txt", "mainPages.txt", "backPages_latex.txt"]
        } else {
            sourceFileList = []
        }
        let items = try sourceFileList
            .map { try Common.getContentsOfFile(path: config.rootDir + "/" + $0) }
            .flatMap { $0 }
            .map { config.markdownLanguageTailoredPath(rootRelativeUntailoredPath: $0) }
        return items
    }
    
    static func replaceFile(path: String, withLines lines: [String]) throws {
        try FileManager.default.removeItem(atPath: path)
        let totalContents = lines.joined(separator: "\n")
        try totalContents.write(toFile: path, atomically: true, encoding: .utf8)

    }
}
