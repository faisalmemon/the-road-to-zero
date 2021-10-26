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
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        return TrademarksInternal(clientLog: log, configuration: config).updateTrademarkMarkdownFile()
    }
    
    public func buildBook() -> BuildResult {
        return buildBook(isSecondTime: false)
    }
    
    internal func buildBook(isSecondTime: Bool) -> BuildResult {
        let builder = BookBuilder(clientLog: log, configuration: config)
        switch builder.build() {
        case .success(let result):
            if result == .RequireSecondRun && isSecondTime == false {
                return buildBook(isSecondTime: true)
            } else if result == .RequireSecondRun && isSecondTime {
                return .BookBuildFailure
            }
            else {
                return .BookBuiltSuccessfully
            }

        case .failure(_):
            return .BookBuildFailure
        }
    }
    
}
