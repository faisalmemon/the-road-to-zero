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

enum GrammarError: Error, CustomStringConvertible {
    case grammarErrorYouReference
    public var description: String {
        switch self {
        case .grammarErrorYouReference:
            return "File has a 'you' reference; not allowed."
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
            if try secondIterationRequiredHavingProcessedTrademark() {
                status = .RequireSecondRun
            }
            try checkGrammar()
            try gutterClean()
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
    
    func secondIterationRequiredHavingProcessedTrademark() throws -> Bool {
        let trademarkResult = TrademarksInternal(clientLog: log, configuration: config).updateTrademarkMarkdownFile()
        if trademarkResult == .TrademarkFileSystemFailure {
            throw TrademarkError.cannotCreateTrademarkFile
        } else if trademarkResult == .TrademarkNotYetIndexed {
            return true
        }
        return false
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
            .map { try Common.getContentsOfFile(path: config.rootDir + "/" + $0) }
            .flatMap { $0 }
            .map { config.markdownLanguageTailoredPath(rootRelativeUntailoredPath: $0) }
        return items
    }
    
    func shouldGrammarCheckFile(file: String) -> Bool {
        let ignoreList = ["Introduction", "Preface", "Acknowledgements"]
        for item in ignoreList {
            if file.contains(item) {
                return false
            }
        }
        return true
    }
    
    func grammarCheckForYouReferences(relativeFilePath: String) throws {
        let lines = try Common.getContentsOfFile(path: config.rootDir + "/" + relativeFilePath).map { $0.lowercased() }
        for line in lines {
            if line.contains("you ") || line.contains("your ") {
                if line.contains(("hammer")) {
                    // allow special case "can feel like your brain has been hit by a hammer"
                    // as it is a colloquial expression
                    continue
                }
                logger.error("file \(relativeFilePath) has a 'you' reference: \(line)")
                throw GrammarError.grammarErrorYouReference
            }
        }
        return
    }
    
    func checkGrammar() throws {
        let fileList = try Set<String>(filesToProcess(bookType: .MarkdownBased))
        let prunedList = fileList.filter { shouldGrammarCheckFile(file: $0) }
        for item in prunedList {
            try grammarCheckForYouReferences(relativeFilePath: item)
        }
    }
    
    func gutterClean() throws {
        let fileList = try Set<String>(filesToProcess(bookType: .MarkdownBased))
        for item in fileList {
            let markdownFold = MarkdownFold(clientLog: log, configuration: config, sourceFile: item)
            try markdownFold.fileFold()
        }
    }
}
