import os.log

import Foundation

public class BuilderLibrary {
    let log: OSLog
    var config: BookBuilderFile
    
    public required init(clientLog: OSLog, configuration: BookBuilderFile) {
        log = clientLog
        config = configuration
    }
}

extension BuilderLibrary: BookBuilderService {
    
    public func build() -> BuildBookResult {
        return .BuildSuccess
    }
    
    public func updateTrademarkMarkdown() -> TrademarkResult {
        return TrademarksInternal(log, config).updateTrademarkMarkdownFile()
    }
    
    public func getBookBuilderFile() -> BookBuilderFile {
        return config
    }
    public func setBookBuilderFile(file: BookBuilderFile) {
        self.config = file
    }
}
