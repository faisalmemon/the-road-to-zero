//
//  BookBuilderFile.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Foundation

public struct BookBuilderFile: Decodable, Encodable {
    public let description: String
    public let rootDirectory: String
    public let trademarksMarkdownFile: String
    public let intermediateOutputDir: String
    public let fileFormatVersion: Int
    
    public static func fromData(_ data: Data) throws -> BookBuilderFile {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let bbf:BookBuilderFile = try decoder.decode(BookBuilderFile.self, from: data)
        return bbf
    }
    
    public static func fromBlank() -> BookBuilderFile {
        let blank = BookBuilderFile(description: "Place description of book here", rootDirectory: "Place full path to parent directory of book here", trademarksMarkdownFile: "trademarks.md", intermediateOutputDir: "generated", fileFormatVersion: 1)
        return blank
    }
    
    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(self)
        return data
    }
}

//MARK:- Convenience Helpers

extension BookBuilderFile {
    public func trademarkInfo() -> TrademarkInfo {
        let trademarksFile = rootDirectory + "/" + trademarksMarkdownFile
        var url = URL(fileURLWithPath: rootDirectory + "/" + intermediateOutputDir)
        url.appendPathComponent("boo.en.idx")
        return TrademarkInfo(trademarksFile: trademarksFile, indexURL: url)
    }
}

