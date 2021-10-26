//
//  BookBuilder.swift
//  
//
//  Created by Faisal Memon on 26/10/2021.
//

import Foundation
import os.log


class BookBuilder {
    let fileManager: FileManager
    let log: OSLog
    let logger: Logger
    let config: Configuration
    
    init(clientLog: OSLog, configuration: Configuration) {
        log = clientLog
        config = configuration
        fileManager = FileManager.default
        logger = Logger(log)
    }
    
    func removeTemporaryFiles() -> Result<Bool, Error> {
        let tempFileUrls = config.getTempFileURLs()
        for item in tempFileUrls {
            do {
                try fileManager.removeItem(at: item)
                logger.info("Removed temporary file: \(item)")
            } catch let error {
                logger.error("Cannot removeItem: \(error.localizedDescription)")
                return .failure(error)
            }
        }
        return .success(true)
    }
}
