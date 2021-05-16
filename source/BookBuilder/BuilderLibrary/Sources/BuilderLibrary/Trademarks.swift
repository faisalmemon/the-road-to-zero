//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

public enum TrademarkResult {
    case TrademarkFileUpdated,
         TrademarkFileSystemFailure,
         TrademarkNotYetIndexed
}

public struct Trademarks {    
    public static func updateTrademarkMarkdown(config: Configuration) -> TrademarkResult {
        let trademarks = TrademarksInternal(configuration: config)
        return trademarks.updateTrademarkMarkdownFile()
    }
}

enum LatexIndex {
    case Entries([String])
    case NotIndexed
}

enum TrademarksInternalError: Error {
    case CannotUTF8EncodeString
}

class TrademarksInternal {
    // Pattern to obtain the capture group that is prefixed with "trademark!"
    // that does not contain a "}", and postfixed with a "}"
    static let pattern = #"trademark!([^\}]*)\}"#
    static let regex = try! NSRegularExpression(pattern: pattern, options: [])

    let config: Configuration
    let fileManager: FileManager
    
    init(configuration: Configuration) {
        config = configuration
        fileManager = FileManager.default
    }
    
    func getLatexIndex() -> LatexIndex {
        let indexFileURL = config.getLatexIndexFileURL()
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
    
    /// Get trademark from an index entry
    /// - Parameter entry: latex index entry e.g. "\\indexentry{trademark!NEXTSTEP}{18}"
    /// - Returns: trademark if present, e.g. NEXTSTEP
    func getTrademarkFromIndexEntry(entry: String) -> String {
        let nsrange = NSRange(entry.startIndex..<entry.endIndex,
                              in: entry)
        var interestingRange: Range<String.Index>?
        TrademarksInternal.regex.enumerateMatches(in: entry, options: [], range: nsrange) { (match, _, stop) in
            guard let match = match else { return }
            
            if match.numberOfRanges == 2 {
                interestingRange = Range(match.range(at: 1), in: entry)
                stop.pointee = true
            }
        }
        if let gotRange = interestingRange {
            let result = String(entry[gotRange])
            return result
        } else {
            return ""
        }
    }
    
    func getTrademarksFromLatexIndex(_ latexIndex: [String]) -> [String] {
        var set: Set<String> = Set()
        for item in latexIndex {
            let extractedTrademark = getTrademarkFromIndexEntry(entry: item)
            if extractedTrademark != "" {
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
        let manager = FileManager.default
        let trademarksFile = config.getMarkdownFilePath()
        if manager.fileExists(atPath: trademarksFile) {
            try manager.removeItem(atPath: trademarksFile)
        }
        manager.createFile(atPath: trademarksFile,
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
