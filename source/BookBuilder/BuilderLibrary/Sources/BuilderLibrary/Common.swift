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
    
    static func replaceFile(path: String, withLines lines: [String]) throws {
        try FileManager.default.removeItem(atPath: path)
        let totalContents = lines.joined(separator: "\n")
        try totalContents.write(toFile: path, atomically: true, encoding: .utf8)

    }
}
