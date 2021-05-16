//
//  RegularExpressionHelper.swift
//  
//
//  Created by Faisal Memon on 16/05/2021.
//

import Foundation

struct RegularExpressionHelper {
    
    static func rangeForString(_ string: String) -> NSRange {
        let nsrange = NSRange(string.startIndex..<string.endIndex,
                              in: string)
        return nsrange
    }
    
    static func trademarkFromLatexIndexEntry(_ latexIndex: String) -> String? {
        // Pattern to obtain the capture group that is prefixed with "trademark!"
        // that does not contain a "}", and postfixed with a "}"
        let pattern = #"trademark!([^\}]*)\}"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsrange = rangeForString(latexIndex)
        var interestingRange: Range<String.Index>?
        regex.enumerateMatches(in: latexIndex, options: [], range: nsrange) { (match, _, stop) in
            guard let match = match else { return }
            
            if match.numberOfRanges == 2 {
                interestingRange = Range(match.range(at: 1), in: latexIndex)
                stop.pointee = true
            }
        }
        if let gotRange = interestingRange {
            let result = String(latexIndex[gotRange])
            return result
        } else {
            return nil
        }
    }
    
}
