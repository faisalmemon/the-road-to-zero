//
//  BookBuilderFile.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Foundation

public struct BookBuilderFile {
    public let description: String
    public let rootDirectory: String
    public let trademarksMarkdownFile: String
    public let intermediateOutputDir: String
    public let fileFormatVersion: Int
    
    public init(description: String, rootDirectory: String, trademarksMarkdownFile: String, intermediateOutputDir: String) {
        self.description = description
        self.rootDirectory = rootDirectory
        self.trademarksMarkdownFile = trademarksMarkdownFile
        self.intermediateOutputDir = intermediateOutputDir
        self.fileFormatVersion = 1
    }
}

public protocol BookBuilderFileDataManagement: Decodable, Encodable {
    /// Create a blank document with placeholder values
    init()
    /// Create a book builder file from serialized data
    /// - Parameter data: JSON serialized data
    init(fromData data: Data) throws
    /// Convert book builder file into JSON serialized data
    func toData() throws -> Data
}

public protocol TrademarkInfoAdapter {
    /// Convert data structure into a trademark information data structure
    func trademarkInfo() -> TrademarkInfo
}

extension BookBuilderFile: BookBuilderFileDataManagement {
    public init() {
        self.init(description: "Place description of book here", rootDirectory: "Place full path to parent directory of book here", trademarksMarkdownFile: "trademarks.md", intermediateOutputDir: "generated")
    }
    
    public init(fromData data: Data) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self = try decoder.decode(BookBuilderFile.self, from: data)
    }
    
    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(self)
        return data
    }
}

extension BookBuilderFile: TrademarkInfoAdapter {
    public func trademarkInfo() -> TrademarkInfo {
        let trademarksFile = rootDirectory + "/" + trademarksMarkdownFile
        var url = URL(fileURLWithPath: rootDirectory + "/" + intermediateOutputDir)
        url.appendPathComponent("boo.en.idx")
        return TrademarkInfo(trademarksFile: trademarksFile, indexURL: url)
    }
}

