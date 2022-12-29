import Foundation

extension NSRegularExpression {
    // func replaceOccurrences(in string: String, through groupLabel: String, _ getReplacementValue: (String) throws -> String) throws -> (Bool, String) {
    func replaceOccurrences(in string: String, through groupLabel: String, _ getReplacementValue: (String) throws -> String) throws -> String {
        var replaced: Bool
        var replacedAny: Bool = false

        var string = string

        repeat {
            replaced = false
            let range = NSRange(location: 0, length: string.count)

            for matchRange in self.matches(in: string, options: [], range: range) {
                if let patternRange = Range(matchRange.range, in: string), let valueRange = Range(matchRange.range(withName: groupLabel), in: string) {
                    if !replaced {
                        replaced = true
                    }

                    if !replacedAny {
                        replacedAny = true
                    }

                    let referencedName = String(string[valueRange])
                    let patternMatch = String(string[patternRange])

                    string = string.replacingOccurrences(of: patternMatch, with: try getReplacementValue(referencedName))

                    break // string has changed, need to discard remaining match ranges because they may not be relevant to the new string
                }
            }
        } while (replaced) // replace all matches in current string

        return string
    }
}
