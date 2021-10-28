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
    
    /// When a line matches, chop it out and the immediately following line.
    ///
    /// [Line Chopping from  StackOverflow](https://stackoverflow.com/questions/56080711/sed-delete-x-lines-after-a-match/56080831#56080831)
    /// ```
    /// sed -e '/if(csl-hanging-indent)/{N;d;}' -i.bak boo.$langName.latex
    /// achieves this:
    /// ➜  ios-crash-dump-analysis-book git:(master) diff boo.en.latex.bak boo.en.latex
    /// 10418,10419d10417
    /// <   {$if(csl-hanging-indent)$\setlength{\parindent}{0pt}%
    /// <   \everypar{\setlength{\hangindent}{\cslhangindent}}\ignorespaces$endif$}%
    ///```
    /// That means when the csl-hanging-indent pattern is seen, chop out that line
    /// an the following line.
    static func chopOutMatchAndFollowingLine(contents: [String], pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        var result = [String]()
        var linesToIgnore = 0
        for line in contents {
            if linesToIgnore > 0 {
                linesToIgnore -= 1
                continue
            }
            let matchResult = regex.matches(in: line, options: [], range: rangeForString(line))
            if matchResult.count > 0 {
                print("got match")
                linesToIgnore = 1
                continue
            } else {
                result.append(line)
            }
        }
        return result
    }
}
