import os.log

import Foundation

public class BuilderLibrary {
    let log: OSLog
    let config: BookBuilderFile
    
    public required init(clientLog: OSLog, configuration: BookBuilderFile) {
        log = clientLog
        config = configuration
    }
}

extension BuilderLibrary: BookBuilderService {
    public static func connectTo(clientLog: OSLog, configuration: BookBuilderFile) -> BookBuilderService {
        return self.init(clientLog: clientLog, configuration: configuration)
    }
    
    public func disconnect() {
        // does nothing at the moment
    }
    
    public func build() {
    }
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        return TrademarksInternal(log, config).updateTrademarkMarkdownFile()
    }
}
