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
    
    func runProcessWith(_ args: [String]) {
        let process = Process()
        process.launchPath = "/usr/local/bin/pandoc"
        process.currentDirectoryPath = config.rootDir
        process.arguments = args
        
        logger.info("PANDOC BUILD COMMAND:")
        logger.info("cd \(process.currentDirectoryPath); /usr/local/bin/pandoc \(args.joined(separator: " "))")
        
        process.launch()
        process.waitUntilExit()
        let result = process.terminationStatus
        if result != 0 {
            logger.error("pandoc returned \(result)")
        } else {
            logger.info("pandoc returned 0")
        }
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

        runProcessWith(args)
    }
    
    func buildIndex() throws {
        let passes = 3
        for pass in 0..<passes {
            logger.info("Indexing pass \(pass)")
            let process = Process()
            process.launchPath = "/Library/TeX/texbin/pdflatex"
            process.currentDirectoryPath = config.outputDir
            process.arguments = [latexOutputFile()]
            let standardOutputPipe = Pipe()
            process.standardOutput = standardOutputPipe
            process.standardInput = FileHandle.nullDevice
            process.terminationHandler = {  process in
                var value: String? = nil
                let data = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
                value = String(bytes: data, encoding: .utf8)
                if let gotOutput = value {
                    logger.info("Latex Index pass \(pass) returned \(gotOutput)")
                } else {
                    logger.info("Latex Index pass \(pass) returned no standard output")
                }
                if process.terminationStatus != 0 {
                    logger.error("Latex Index pass \(pass) returned error \(process.terminationStatus)")
                }
            }
            process.launch()
            process.waitUntilExit()
        }
    }

    
    func latexOutputFile() -> String {
        let outputLangLatex = config.outputDir + "/boo." + config.language + ".latex"
        return outputLangLatex
    }
    
    func documentBuildLatex() throws {
        //pandoc $latexFilesToProcess pandocMetaData.yaml --resource-path=$scriptPath:$scriptPath/diagrams:$scriptPath/screenshots --citeproc --bibliography=bibliography.bib -f markdown+smart --standalone --toc --template=style/styleToCreateIndex.latex -V documentclass=book -o $outputDir/boo.$langName.latex
        let filesToProcess = try Common.filesToProcess(config: config, bookType: .LatexBased)
        let outputLangLatex = latexOutputFile()
        var args = [String]()
        args.append(contentsOf: filesToProcess)
        args.append(config.getPandocMetaDataYamlFilePath())
        args.append("--resource-path=\(config.rootDir):\(config.rootDir)/diagrams:\(config.rootDir)/screenshots")
        args.append("--citeproc")
        args.append("--bibliography=\(config.getBibliographyBibFilePath())")
        args.append("-f")
        args.append("markdown+smart")
        args.append("--standalone")
        args.append("--toc")
        args.append("--template=\(config.styleToCreateIndexFilePath())")
        args.append("-V")
        args.append("documentclass=book")
        args.append("-o")
        args.append(outputLangLatex)

        runProcessWith(args)
        
        if false {
            let lines = try Common.getContentsOfFile(path: outputLangLatex, throwAwayEmptyLines: false)
            let truncatedLines = RegularExpressionHelper.chopOutMatchAndFollowingLine(contents: lines, pattern: #"if(csl-hanging-indent)|cslhangindent|cslreferences|CSLReferences"#)
            
            try Common.replaceFile(path: outputLangLatex, withLines: truncatedLines)
        }
        
        try buildIndex()
    }
}
