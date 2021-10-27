//
//  MarkdownFold.swift
//  
//
//  Created by Faisal Memon on 27/10/2021.
//

import Foundation
import os.log

struct MarkdownFold {
    let log: OSLog
    let config: Configuration
    let tabLength: Int
    let width: Int
    let fileName: String
    let logger: Logger
    
    init(clientLog: OSLog, configuration: Configuration,
         sourceFile: String,
         tabLength: Int = 8, width: Int = 65) {
        log = clientLog
        config = configuration
        logger = Logger(clientLog)

        fileName = configuration.rootDir + "/" + sourceFile
        self.tabLength = tabLength
        self.width = width
    }
    
    func columnContributionFromTab(_ column: Int) -> Int {
        // 0 - 8
        // 1 - 7
        // 7 - 1
        // 8 - 8
        if tabLength < 1 {
            return 0
        }
        let result = tabLength - (column % tabLength)
        return result;

    }
    
    func lineVisualLengthWithTabs(_ line: String) -> Int {
        var columnPosition = 0
        for char in line {
            if char == "\t" {
                columnPosition += columnContributionFromTab(columnPosition)
            } else {
                columnPosition += 1
            }
        }
        
        // don't count trailing newline
        if line.last == "\n" {
            columnPosition -= 1
        }
        return columnPosition
    }
    
    func lineFold(_ line: String, foldedLines: inout [String]) {
        var columnPosition = 0
        var whiteSpacePosition = line.startIndex
        var savedIndex = line.startIndex
        for index in line.indices {
            savedIndex = index
            if line[index] == "\n" {
                break
            } else if columnPosition > width {
                break
            } else if line[index] == "\t" {
                whiteSpacePosition = index
                columnPosition += columnContributionFromTab(columnPosition)
            } else if line[index] == " " {
                whiteSpacePosition = index
                columnPosition += 1
            } else {
                columnPosition += 1
            }
        }
        if columnPosition <= width {
            foldedLines.append(line)
            // no more work needed; exit
            return
        } else if whiteSpacePosition > line.startIndex {
            foldedLines.append(String(line[..<whiteSpacePosition]))
            lineFold(String(line[whiteSpacePosition...]), foldedLines: &foldedLines)
        } else {
            foldedLines.append(String(line[..<savedIndex]))
            lineFold(String(line[savedIndex...]), foldedLines: &foldedLines)
        }
    }
    
    func fileFold() throws {
        var insideVerboseBlock = false
        var output = [ String]()
        do {
            let lines = try Common.getContentsOfFile(path: fileName, throwAwayEmptyLines: false)
            for line in lines {
                if line == "```" || line == "```c" {
                    logger.info("Found back ticks")
                    insideVerboseBlock.toggle()
                }
                if insideVerboseBlock {
                    let lineLength = lineVisualLengthWithTabs(line)
                    if lineLength <= width {
                        output.append(line)
                    } else {
                        lineFold(line, foldedLines: &output)
                    }
                } else {
                    output.append(line)
                }
            }
        } catch let error {
            logger.error("fold error: \(error.localizedDescription)")
            throw error
        }
        for debugLine in output {
            logger.info("len \(debugLine.count): \(debugLine)")
        }
        try Common.replaceFile(path: fileName, withLines: output)
    }
}
