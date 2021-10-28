//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation
import os.log

//MARK:- Internal Interface

enum LatexIndex {
    case Entries([String])
    case NotIndexed
}

enum TrademarksInternalError: Error {
    case CannotUTF8EncodeString
}

typealias Rex = RegularExpressionHelper

class TrademarksInternal {
    let fileManager: FileManager
    let trademarksFile: String
    let indexFile: String
    let log: OSLog
    let logger: Logger

    
    init(clientLog: OSLog, configuration: Configuration) {
        log = clientLog
        trademarksFile = configuration.getMarkdownFilePath()
        indexFile = configuration.getLatexIndexFile()
        fileManager = FileManager.default
        logger = Logger(log)
    }
    
    func getLatexIndex() -> LatexIndex {
        do {
            let stringArray = try Common.getContentsOfFile(path: indexFile, throwAwayEmptyLines: true)
            return LatexIndex.Entries(stringArray)
        } catch {
            logger.error("Latex entries info: \(error.localizedDescription)")
            return LatexIndex.NotIndexed
        }
    }
    
    func getTrademarksFromLatexIndex(_ latexIndex: [String]) -> [String] {
        var set: Set<String> = Set()
        for item in latexIndex {
            if let extractedTrademark = Rex.trademarkFromLatexIndexEntry(item) {
                set.insert(extractedTrademark)
            }
        }
        let array = Array(set).sorted()
        return array
    }
    
    func updateTrademarkMarkdownFile() -> TrademarkResult {
        switch getLatexIndex() {
        case .NotIndexed:
            return TrademarkResult.TrademarkNotYetIndexed
        case .Entries(let entries):
            do {
                try Common.replaceFile(path: trademarksFile, withLines: entries)
            } catch {
                logger.error("replace trademarks gave \(error.localizedDescription)")
                return TrademarkResult.TrademarkFileSystemFailure
            }
            return TrademarkResult.TrademarkFileUpdated
        }
    }
}
