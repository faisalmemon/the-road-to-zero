//
//  Typesetter.swift
//  
//
//  Created by Faisal Memon on 28/10/2021.
//

import Foundation
import os.log

struct Typesetter {
    let log: OSLog
    let config: Configuration

    let logger: Logger
    
    init(clientLog: OSLog, configuration: Configuration) {
        log = clientLog
        config = configuration
        logger = Logger(clientLog)
    }
    
    func documentBuildHtml() throws {
        let filesToProcess = try Common.filesToProcess(config: config, bookType: .MarkdownBased)
        let outputLangHtml = config.outputDir + "/foo." + config.language + ".html"
        var args = [String]()
        args.append(contentsOf: filesToProcess)
        args.append(config.getPandocMetaDataYamlFilePath())
        args.append("-s")
        args.append("--citeproc")
        args.append("--bibliography=\(config.getBibliographyBibFilePath())")
        args.append("-f")
        args.append("markdown+smart")
        args.append("--standalone")
        args.append("--toc")
        args.append("-c")
        args.append("\(config.getGitHubStyleFilePath())")
        args.append("-o")
        args.append(outputLangHtml)

        let task = Process()
        task.launchPath = "/usr/local/bin/pandoc"
        task.currentDirectoryPath = config.rootDir
        task.arguments = args
        logger.info("PANDOC BUILD COMMAND:")
        logger.info("cd \(task.currentDirectoryPath); /usr/local/bin/pandoc \(args.joined(separator: " "))")
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                DispatchQueue.main.async {
                    logger.log("html \(config.language): \(line)")
                }
            } else {
                logger.error("Error decoding data: \(pipe.availableData)")
            }
        }
        task.launch()
        task.waitUntilExit()
        let result = task.terminationStatus
        if result != 0 {
            logger.error("pandoc returned \(result)")
        } else {
            logger.info("pandoc returned 0")
        }
    }
}
