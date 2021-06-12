//
//  BookBuilderService.swift
//  
//
//  Created by Faisal Memon on 05/06/2021.
//

import os.log

import Foundation

public enum TrademarkResult {
    case TrademarkFileUpdated,
         TrademarkFileSystemFailure(Error),
         TrademarkNotYetIndexed
}

public enum BuildBookResult {
    case BuildSuccess
    case BuildSystemFailure(Error)
}

public protocol BookBuilderService {
    init(clientLog: OSLog, configuration: BookBuilderFile)
    func build() -> BuildBookResult
    func updateTrademarkMarkdown() -> TrademarkResult
}
