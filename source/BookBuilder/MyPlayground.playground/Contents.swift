import Cocoa

var str = "Hello, playground"

let pattern = #"trademark!(.*)\}"#
let regex = try! NSRegularExpression(pattern: pattern, options: [])

