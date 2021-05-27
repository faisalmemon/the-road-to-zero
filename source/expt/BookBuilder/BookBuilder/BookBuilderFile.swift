//
//  BookBuilderFile.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Foundation

struct BookBuilderFile: Decodable {
    let description: String
    let trademarksMarkdownFile: String
    let intermediateOutputDir: String
    let fileFormatVersion: Int
    
    static func fromData(_ data: Data) throws -> BookBuilderFile {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let bbf:BookBuilderFile = try decoder.decode(BookBuilderFile.self, from: data)
        return bbf
    }
}
