import Foundation

enum AttributeReferenceResolutionError: Error {
    case missing(attribute: String)
    case recursiveReferencesAreForbidden(of: String)
}

extension Expander {
    static let nameKeySeparator = ";"
    static let nameKeyValueSeparator = "="
    static let missingValueMark = "-"
    static let valueSeparator = ","

    func gatherNameComponents(config: Any, result: inout [String: Any]) -> Any {
        if let config = config as? [String: Any] {
            var updatedConfig = [String: Any]()

            for (key, value) in config {
                if key.starts(with: ConfigSpec.prefixMark) {
                    if let existingValue = result[key.withoutPrefixMark] { // may come from another element of array
                        result[key.withoutPrefixMark] = "\(existingValue)\(Expander.valueSeparator)\(value)"
                    } else {
                        result[key.withoutPrefixMark] = value
                    }
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

        for (key, value) in updatedConfig {
            if let value = value as? String {
                updatedConfig[key] = try NSRegularExpression(pattern: "\\{\\{(?<attribute>[^}{]+)\\}\\}").replaceOccurrences(in: value, through: "attribute") { attribute in
                    if attribute == key {
                        throw AttributeReferenceResolutionError.recursiveReferencesAreForbidden(of: attribute)
                    }
                    if let referencedValue = updatedConfig[attribute] as? String {
                        return referencedValue
                    } else {
                        throw AttributeReferenceResolutionError.missing(attribute: attribute)
                    }
                }
            }
        }

        return updatedConfig
    }
}
