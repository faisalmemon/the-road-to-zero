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
    
    public func build() -> BuildBookResult{
        return .BuildSystemFailure(NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
)
    }
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        return TrademarksInternal(log, config).updateTrademarkMarkdownFile()
    }
}
