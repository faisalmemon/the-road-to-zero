//
//  BookBuilderFile.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Foundation

public struct BookBuilderFile: Decodable {
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

