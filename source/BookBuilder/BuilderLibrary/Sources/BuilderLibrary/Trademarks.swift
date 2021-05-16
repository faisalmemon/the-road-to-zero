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
    let indexFileURL: URL
    let log: OSLog
    
    init(clientLog: OSLog, configuration: Configuration) {
        log = clientLog
        trademarksFile = configuration.getMarkdownFilePath()
        indexFileURL = configuration.getLatexIndexFileURL()
        fileManager = FileManager.default
    }
    
    func getLatexIndex() -> LatexIndex {
        do {
            let fullStringContents =
                try String(contentsOf: indexFileURL, encoding: .utf8)
            let stringArray =
                fullStringContents.components(separatedBy: .newlines)
            return LatexIndex.Entries(stringArray)
        } catch {
            print("Latex entries info: \(error)")
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
        if fileManager.fileExists(atPath: trademarksFile) {
            try fileManager.removeItem(atPath: trademarksFile)
        }
        fileManager.createFile(atPath: trademarksFile,
                           contents: data,
                           attributes: [:])
    }
    
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
                print("replace trademarks gave " + error.localizedDescription)
                return TrademarkResult.TrademarkFileSystemFailure
            }
            return TrademarkResult.TrademarkFileUpdated
        }
    }
}
