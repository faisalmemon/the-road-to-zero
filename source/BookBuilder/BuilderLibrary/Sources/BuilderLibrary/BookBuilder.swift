//
//  BookBuilder.swift
//  
//
//  Created by Faisal Memon on 26/10/2021.
//

import Foundation
import os.log

enum TrademarkError: Error {
    case cannotCreateTrademarkFile
}

extension TrademarkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cannotCreateTrademarkFile:
            return "Cannot create trademarks file."
        }
    }
}

enum BookBuildResult {
    case BuildSuccess,
    RequireSecondRun
}

enum BookType {
    case LatexBased,
    MarkdownBased
}

class BookBuilder {
    let fileManager: FileManager
    let logger: Logger
    let log: OSLog
    let config: Configuration
    
    init(clientLog: OSLog, configuration: Configuration) {
        config = configuration
        logger = Logger(clientLog)
        log = clientLog
        fileManager = FileManager.default
    }
    
    func build() -> Result<BookBuildResult, Error> {
        var status = BookBuildResult.BuildSuccess
        
        do {
            try outputDirectoryCreateIfNeeded()
            try temporaryFilesRemoveAll()
            let trademarkResult = TrademarksInternal(clientLog: log, configuration: config).updateTrademarkMarkdownFile()
            if trademarkResult == .TrademarkFileSystemFailure {
                throw TrademarkError.cannotCreateTrademarkFile
            } else if trademarkResult == .TrademarkNotYetIndexed {
                status = .RequireSecondRun
            }
        } catch let error {
            logger.error("\(error.localizedDescription)")
            return .failure(error)
        }
        return .success(status)
    }
    
    func outputDirectoryCreateIfNeeded() throws {
        let outputDir = config.outputDir
        if fileManager.fileExists(atPath: outputDir) {
            return
        }
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: [:])
        logger.info("Created output directory: \(outputDir)")
        return
    }
    
    func temporaryFilesRemoveAll() throws {
        let tempFileUrls = config.getTempFileURLs()
        for item in tempFileUrls {
            try fileManager.removeItem(at: item)
            logger.info("Removed temporary file: \(item)")
        }
        return
    }
    
    func getContentsOfFile(path: String) throws -> [String]  {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let strings = data.components(separatedBy: .newlines)
        return strings
    }
    
    func filesToProcess(bookType: BookType) throws -> [String] {
        
        let sourceFileList: [String]
        
        if bookType == .MarkdownBased {
            sourceFileList = ["frontPages.txt", "mainPages.txt"]
        } else if bookType == .LatexBased {
            sourceFileList = ["frontPages_latex.txt", "mainPages.txt", "backPages_latex.txt"]
        } else {
            sourceFileList = []
        }
        let items = try sourceFileList
            .map { try getContentsOfFile(path: config.rootDir + "/" + $0) }
            .flatMap { $0 }
            .map { config.markdownLanguageTailoredPath(rootRelativeUntailoredPath: $0) }
        return items
    }
}
