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
         TrademarkFileSystemFailure,
         TrademarkNotYetIndexed
}

public protocol BookBuilderService {
    init(clientLog: OSLog, configuration: BookBuilderFile)
    func disconnect()
    func build()
    func updateTrademarkMarkdown() -> TrademarkResult
}
