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

    func gatherNameComponents(_ configs: [[String: Any]]) -> [[String: Any]] {
        return configs.map{ config in
            var name = [String: Any]()
            let namePrefix = config[nameKey]

            var config = gatherNameComponents(config: config, result: &name) as! [String: Any]

            let joinedName = String(
                name.keys.sorted().map { key in
                    "\(key)\(Expander.nameKeyValueSeparator)\(name[key] ?? Expander.missingValueMark)"
                }.joined(separator: Expander.nameKeySeparator)
            ).joinIfNotNone(prefix: namePrefix as? String, separator: Expander.nameKeySeparator)

            config[nameKey] = joinedName

            return config
        }
    }
}
