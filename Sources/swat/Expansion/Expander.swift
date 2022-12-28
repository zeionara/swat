struct Expander {
    static let nameKeySeparator = ";"
    static let nameKeyValueSeparator = "="
    static let missingValueMark = "-"

    enum KeyError: Error {
        case missingValue(forKey: String)
    }

    var nameKey: String = "name"

    private func gatherNameComponents(config: Any, result: inout [String: Any]) -> Any {
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

    internal func expand(config: ConfigSpec) throws -> [[String: Any]] {
        return try expand(config: config, isRecursiveCall: false)
    }

    internal func expand(config: ConfigSpec, isRecursiveCall: Bool) throws -> [[String: Any]] {
        var name = [String: Any]()
        let result = try expand(configs: [config], keys: config.dict.map{ $0.key }.sorted(), name: &name).map{ $0.dict }
        // print(name)

        if (!isRecursiveCall) {
            // print("--", result)

            return result.map{ config in
                var name = [String: Any]()
                let namePrefix = config[nameKey]

                var config = gatherNameComponents(config: config, result: &name) as! [String: Any]

                let joinedName = String(
                    name.keys.sorted().map { key in
                        "\(key)\(Expander.nameKeyValueSeparator)\(name[key] ?? Expander.missingValueMark)"
                    }.joined(separator: Expander.nameKeySeparator)
                ).joinIfNotNone(prefix: namePrefix as? String, separator: Expander.nameKeySeparator)

                // print(joinedName)
                config[nameKey] = joinedName
                return config
                // print(config)
            }
        }

        return result
    }

    internal func expand(configs: [ConfigSpec], keys: [String], name: inout [String: Any]) throws -> [ConfigSpec] {
        guard let key = keys.first else {
            return configs
        }

        var updatedConfigs = [ConfigSpec]()

        try configs.forEach { (config) throws -> Void in
            var updatedConfig = config.dict

            if let value = updatedConfig.removeValue(forKey: key) {

                // expand list

                if let items = value as? [Any] {
                    try updatedConfigs.append(expansionsOf: &updatedConfig, on: items, at: key, spec: config, expander: self, name: &name)
                    return
                }

                // expand object

                if let nestedConfig = value as? [String: Any] {
                    try updatedConfigs.append(expansionsOf: &updatedConfig, on: nestedConfig, at: key, spec: config, expander: self, name: &name)
                    return
                }

                // expand value of a basic type (number, string, etc)

                updatedConfig[key] = value
                updatedConfigs.append(ConfigSpec(dict: updatedConfig, yaml: config.yaml))
            } else {
                throw KeyError.missingValue(forKey: key) // TODO: Raise an exception
            }

        }

        return try expand(configs: updatedConfigs, keys: Array(keys.dropFirst()), name: &name)
    }

}
