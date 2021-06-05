import os.log

import Foundation

public enum TrademarkResult {
    case TrademarkFileUpdated,
         TrademarkFileSystemFailure,
         TrademarkNotYetIndexed
}

public class BuilderLibrary {
    let log: OSLog
    let config: BookBuilderFile
   
    public init(clientLog: OSLog, configuration: BookBuilderFile) {
        log = clientLog
        config = configuration
    }
}

extension BuilderLibrary {
    
    public func build() {
    }
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        let trademarkInfo = TrademarkInfo(withBookBuilderFile: config)
        return TrademarksInternal(log, trademarkInfo).updateTrademarkMarkdownFile()
    }
    
}
