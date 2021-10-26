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
    
    func build() -> Result<Bool, Error> {
        do {
            try outputDirectoryCreateIfNeeded()
            try temporaryFilesRemoveAll()
            let trademarkResult = TrademarksInternal(clientLog: log, configuration: config).updateTrademarkMarkdownFile()
            if trademarkResult == .TrademarkFileSystemFailure {
                throw TrademarkError.cannotCreateTrademarkFile
            }
        } catch let error {
            logger.error("\(error.localizedDescription)")
            return .failure(error)
        }
        return .success(true)
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
}
