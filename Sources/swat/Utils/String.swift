import Foundation

extension String {
    var url: URL {
        return URL(fileURLWithPath: self)
    }

    var fileName: String {
        return self.url.lastPathComponent
    }

    var folderPath: URL {
        return self.url.deletingLastPathComponent()
    }

    func camelCased(with separator: Character) -> String {
        // Implementation from https://stackoverflow.com/questions/48849452/swift-3-4-dash-to-camel-case-snake-to-camelcase
        return self.lowercased()
            .split(separator: separator)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }

    var fromKebabCase: String {
        return camelCased(with: "-")
    }

    func joinIfNotNone(prefix: String?, separator: String) -> String {
        if let prefix = prefix {
            if self.count == 0 {
                return prefix
            }
            return [prefix, self].joined(separator: separator)
        }
        return self
    }

    // func replaceOccurrences(in string: String, through groupLabel: String, _ getReplacementValue: (String) throws -> String) throws -> (Bool, String) {
    func replaceOccurrences(in string: String, through groupLabel: String, _ getReplacementValue: (String) throws -> String) throws -> String {
        var replaced: Bool
        var replacedAny: Bool = false

        var string = string

        let range = NSRange(location: 0, length: string.count)

        let regex = try NSRegularExpression(pattern: self)

        repeat {
            replaced = false

            for matchRange in regex.matches(in: string, options: [], range: range) {
                if let patternRange = Range(matchRange.range, in: self), let valueRange = Range(matchRange.range(withName: groupLabel), in: self) {
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
