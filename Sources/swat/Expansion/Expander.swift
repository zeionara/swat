struct Expander {
    enum KeyError: Error {
        case missingValue(forKey: String)
    }

    var nameKey: String = "name"

    func expand(config: ConfigSpec) throws -> [[String: Any]] {  // convenience interface for the expand method, which takes only one parameter and hence can be piped
        return try expand(config: config, isRecursiveCall: false)
    }

    func expand(config: ConfigSpec, isRecursiveCall: Bool) throws -> [[String: Any]] {
        let configs = try expand(configs: [config], keys: config.dict.map{ $0.key }.sorted()).map{ $0.dict }

        if isRecursiveCall {
            return configs
        }

        return gatherNameComponents(configs)
    }

    func expand(configs: [ConfigSpec], keys: [String]) throws -> [ConfigSpec] {
        guard let key = keys.first else {
            return configs
        }

        var updatedConfigs = [ConfigSpec]()

        try configs.forEach { (config) throws -> Void in
            var updatedConfig = config.dict

            if let value = updatedConfig.removeValue(forKey: key) {

                // expand list

                if let items = value as? [Any] {
                    try updatedConfigs.append(expansionsOf: &updatedConfig, on: items, at: key, spec: config, expander: self)
                    return
                }

                // expand object

                if let nestedConfig = value as? [String: Any] {
                    try updatedConfigs.append(expansionsOf: &updatedConfig, on: nestedConfig, at: key, spec: config, expander: self)
                    return
                }

                // expand value of a basic type (number, string, etc)

                updatedConfig[key] = value
                updatedConfigs.append(ConfigSpec(dict: updatedConfig, yaml: config.yaml))
            } else {
                throw KeyError.missingValue(forKey: key) // TODO: Raise an exception
            }

        }

        return try expand(configs: updatedConfigs, keys: Array(keys.dropFirst()))
    }

}
