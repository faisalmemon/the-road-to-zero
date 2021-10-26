import os.log

public enum TrademarkResult {
    case TrademarkFileUpdated,
         TrademarkFileSystemFailure,
         TrademarkNotYetIndexed
}
public enum BuildResult {
    case BookBuiltSuccessfully,
         BookBuildFailure
}

public class BuilderLibrary {
    
    let log: OSLog
    let config: Configuration
    
    public init(clientLog: OSLog, configuration: Configuration) {
        log = clientLog
        config = configuration
    }
    
    public func build() {
    }
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        return TrademarksInternal(clientLog: log, configuration: config).updateTrademarkMarkdownFile()
    }
    
    public func buildBook() -> BuildResult {
        let builder = BookBuilder(clientLog: log, configuration: config)
        switch builder.removeTemporaryFiles() {
        case .success(_):
            return .BookBuiltSuccessfully
        case .failure(_):
            return .BookBuildFailure
        }
    }
    
}
