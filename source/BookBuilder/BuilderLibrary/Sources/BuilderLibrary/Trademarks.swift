//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

public struct Trademarks {
    public static func findTrademarks(config: Configuration) -> String? {
        let trademarks = TrademarksInternal(configuration: config)
        if let array = trademarks.getTrademarks() {
            return array.joined(separator: ", ")
        }
        return nil
    }
}

class TrademarksInternal {
    
    /// The file containing the trademark index entries
    static let indexFileFromLatex = "boo.en.idx"

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
    
    func getIndexEntries() -> [String]? {
        var indexFileURL = URL(fileURLWithPath: config.outputDir)
        indexFileURL.appendPathComponent(TrademarksInternal.indexFileFromLatex)
        do {
            let fullStringContents =
                try String(contentsOf: indexFileURL, encoding: .utf8)
            let stringArray =
                fullStringContents.components(separatedBy: .newlines)
            return stringArray
        } catch {
            print("Error info: \(error)")
            return nil
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
    
    func getTrademarks() -> [String]? {
        if let listOfTrademarks = getIndexEntries() {
            var set: Set<String> = Set()
            for item in listOfTrademarks {
                let extractedTrademark = getTrademarkFromIndexEntry(entry: item)
                if extractedTrademark != "" {
                    set.insert(extractedTrademark)
                }
            }
            let array = Array(set).sorted()
            return array
        }
        return nil
    }
}
