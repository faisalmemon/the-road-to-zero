//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

public struct Trademarks {
    public static func findTrademarks(config: Configuration) -> String {
        let trademarks = TrademarksInternal(configuration: config)
        let result = trademarks.getIndexEntries()
        if let gotResult = result?.first {
            return gotResult
        } else {
            return ""
        }
    }
}

class TrademarksInternal {
    let config: Configuration
    let fileManager: FileManager
    
    init(configuration: Configuration) {
        config = configuration
        fileManager = FileManager.default
    }
    
    func getIndexEntries() -> [String]? {
        var indexFileURL = URL(fileURLWithPath: config.outputDir)
        indexFileURL.appendPathComponent("boo.en.idx")
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
}
