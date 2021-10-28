//
//  File.swift
//  
//
//  Created by Faisal Memon on 14/05/2021.
//

import Foundation

public struct Configuration {    
    public let language: String
    public let outputDir: String
    public let rootDir: String
    
    let manager = FileManager.default
    
    public init(root: String, lang: String, output: String) {
        rootDir = root
        language = lang
        outputDir = output
    }
    
    public func getLatexIndexFile() -> String {
        return outputDir + "/" + "boo.en.idx"
    }
    
    public func getMarkdownFilePath() -> String {
        return rootDir + "/" + "trademarks.md"
    }
    
    public func getTempFileURLs() -> [URL] {
        var urls = [URL]()
        let fooPrefix = "foo." + language + "."
        let booPrefix = "boo." + language + "."

        let dirEnum = manager.enumerator(atPath: outputDir)

        while let filename = dirEnum?.nextObject() as? String {
            if filename.hasPrefix(fooPrefix) || filename.hasPrefix(booPrefix) {
                urls.append(URL(fileURLWithPath: outputDir + "/" + filename))
            }
        }
        return urls
    }
    
    public func getPandocMetaDataYamlFilePath() -> String {
        return rootDir + "/" + "pandocMetaData.yaml"
    }
    
    public func getBibliographyBibFilePath() -> String {
        return rootDir + "/" + "bibliography.bib"
    }

    public func styleToCreateIndexFilePath() -> String {
        return rootDir + "/style/styleToCreateIndex.latex"
    }
    
    public func getGitHubStyleFilePath() -> String {
        return rootDir + "/style/gitHubStyle.css"
    }
    
    public func markdownLanguageTailoredPath(rootRelativeUntailoredPath untailoredPath: String) -> String {
        if language == "en" {
            return untailoredPath
        }
        let leafName = (untailoredPath as NSString).lastPathComponent
        let candidatePath = rootDir + "/" + language + "/" + "markdown" + "/" + leafName
        if manager.fileExists(atPath: candidatePath) {
            return candidatePath
        } else {
            return untailoredPath
        }
    }
}
