import os.log

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
    
    public func build() {
    }
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        return TrademarksInternal(clientLog: log, configuration: config).updateTrademarkMarkdownFile()
    }
    
}
