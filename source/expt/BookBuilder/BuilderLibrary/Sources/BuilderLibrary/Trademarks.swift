//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation
import os.log

public struct TrademarkInfo {
    let trademarksFile: String
    let indexURL: URL
}

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
    let log: OSLog
    let logger: Logger
    let info: TrademarkInfo

    
    init(_ clientLog: OSLog, _ config: BookBuilderFile) {
        log = clientLog
        info = config.trademarkInfo()
        fileManager = FileManager.default
        logger = Logger(log)
    }
    
    func getLatexIndex() -> LatexIndex {
        do {
            let fullStringContents =
                try String(contentsOf: info.indexURL, encoding: .utf8)
            let stringArray =
                fullStringContents.components(separatedBy: .newlines)
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
    
    func sentenceFromTrademarks(_ trademarks: [String]) -> String {
        return trademarks.joined(separator: ", ").appending(".\n")
    }
    
    func replaceTrademarksMarkdownFileWith(_ sentence: String) throws {
        guard let data = sentence.data(using: .utf8) else {
            throw TrademarksInternalError.CannotUTF8EncodeString
        }
        if fileManager.fileExists(atPath: info.trademarksFile) {
            try fileManager.removeItem(atPath: info.trademarksFile)
        }
        fileManager.createFile(atPath: info.trademarksFile,
                           contents: data,
                           attributes: [:])
    }
    
    //MARK:- External Interface

    func updateTrademarkMarkdownFile() -> TrademarkResult {
        switch getLatexIndex() {
        case .NotIndexed:
            return TrademarkResult.TrademarkNotYetIndexed
        case .Entries(let entries):
            let trademarks = getTrademarksFromLatexIndex(entries)
            let sentence = sentenceFromTrademarks(trademarks)
            do {
                try replaceTrademarksMarkdownFileWith(sentence)
            } catch {
                logger.error("replace trademarks gave \(error.localizedDescription)")
                return TrademarkResult.TrademarkFileSystemFailure
            }
            return TrademarkResult.TrademarkFileUpdated
        }
    }
}


