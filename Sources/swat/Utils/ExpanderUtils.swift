import Foundation

enum AttributeReferenceResolutionError: Error {
    case missing(attribute: String)
}

extension Expander {
    static let nameKeySeparator = ";"
    static let nameKeyValueSeparator = "="
    static let missingValueMark = "-"

    func gatherNameComponents(config: Any, result: inout [String: Any]) -> Any {
        if let config = config as? [String: Any] {
            var updatedConfig = [String: Any]()

            for (key, value) in config {
                if key.starts(with: ConfigSpec.prefixMark) {
                    result[key.withoutPrefixMark] = value
                } else {
                    updatedConfig[key] = gatherNameComponents(config: value, result: &result)
                }
            }

            return updatedConfig
        } else if let items = config as? [Any] {
            return items.map{
                gatherNameComponents(config: $0, result: &result)
            }
        } else {
            return config
        }
    }

    func gatherNameComponentsAndResolveAttributeReferences(_ configs: [ConfigSpec]) throws -> [[String: Any]] {
        return try configs.map{ config in
            let config = try Expander.resolvingAttributeReferences(in: config.dict)

            var name = [String: Any]()
            let namePrefix = config[nameKey]

            var configWithoutNameComponents = gatherNameComponents(config: config, result: &name) as! [String: Any]

            let joinedName = String(
                name.keys.sorted().map { key in
                    "\(key)\(Expander.nameKeyValueSeparator)\(name[key] ?? Expander.missingValueMark)"
                }.joined(separator: Expander.nameKeySeparator)
            ).joinIfNotNone(prefix: namePrefix as? String, separator: Expander.nameKeySeparator)

            configWithoutNameComponents[nameKey] = joinedName

            return configWithoutNameComponents
        }
    }

    static func resolvingAttributeReferences(in config: [String: Any]) throws -> [String: Any] {
        var updatedConfig = config
        var nResolvedReferences: Int

        repeat {
            nResolvedReferences = 0

            for (key, value) in updatedConfig {
                var resolved = false

                if let value = value as? String {

                    let range = NSRange(location: 0, length: value.count)

                    let regex = try! NSRegularExpression(pattern: "\\{\\{(?<attribute>[^}{]+)\\}\\}")

                    for matchRange in regex.matches(in: value, options: [], range: range) {
                        // if let valueRange = Range(matchRange.range, in: value) {
                        if let patternRange = Range(matchRange.range, in: value), let valueRange = Range(matchRange.range(withName: "attribute"), in: value) {
                            nResolvedReferences += 1

                            let referencedName = String(value[valueRange])
                            let patternMatch = String(value[patternRange])

                            if let referencedValue = updatedConfig[referencedName] as? String {
                                updatedConfig[key] = value.replacingOccurrences(of: patternMatch, with: referencedValue)
                                resolved = true
                            } else {
                                throw AttributeReferenceResolutionError.missing(attribute: referencedName)
                            }

                            // print("found caputure:", referencedName, patternMatch)
                            break
                        }
                    
                    }

                    // print(value)
                }

                if !resolved {
                    updatedConfig[key] = value
                }
            }
        } while (nResolvedReferences > 0)

        return updatedConfig
    }
}
