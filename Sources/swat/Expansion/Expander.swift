struct Expander {
    enum KeyError: Error {
        case missingValue(forKey: String)
    }

    enum CastingError: Error {
        case isNotConfig(type: Any.Type)
    }

    var nameKey: String = "name"

    func expand(as type: Any.Type?) throws -> (ConfigSpec) throws -> [[String: Any]] {  // type parameter is used for taking decisions when handling lists - whether they should be expanded or not
        return { config in
            if let unwrappedType = type {
                if let unwrappedTypeAsConfig = unwrappedType as? Config.Type {
                    return try expand(config: config, as: unwrappedTypeAsConfig, isRecursiveCall: false)
                } else {
                    throw CastingError.isNotConfig(type: unwrappedType)
                }
            } else {
                return try expand(config: config, as: nil, isRecursiveCall: false)
            }
        }
    }

    func expand(config: ConfigSpec) throws -> [[String: Any]] {  // convenience interface for the expand method, which takes only one parameter and hence can be piped
        return try expand(config: config, as: nil, isRecursiveCall: false)
    }

    func expand(config: ConfigSpec, as type: Config.Type?, isRecursiveCall: Bool) throws -> [[String: Any]] {
        let configs = try expand(configs: [config], keys: config.dict.map{ $0.key }.sorted(), as: type)

        if isRecursiveCall {
            return try configs.map{ try Expander.resolvingAttributeReferences(in: $0.dict) }
        }

        return try gatherNameComponentsAndResolveAttributeReferences(configs)
    }

    func expand(configs: [ConfigSpec], keys: [String], as type: Config.Type?) throws -> [ConfigSpec] {
        guard let key = keys.first else {
            return configs
        }

        var updatedConfigs = [ConfigSpec]()

        try configs.forEach { (config) throws -> Void in
            var updatedConfig = config.dict

            if let value = updatedConfig.removeValue(forKey: key) {

                // print(try? type?.type(of: key))

                // expand list

                if let items = value as? [Any] {
                    try updatedConfigs.append(expansionsOf: &updatedConfig, on: items, at: key, spec: config, expander: self, as: type)
                    return
                }

                // expand object

                if let nestedConfig = value as? [String: Any] {
                    // try updatedConfigs.append(expansionsOf: &updatedConfig, on: nestedConfig, at: key, spec: config, expander: self, as: type)
                    try updatedConfigs.append(expansionsOf: &updatedConfig, on: nestedConfig, at: key, spec: config, expander: self, childAs: type?.type(of: key) as? Config.Type)
                    return
                }

                // expand value of a basic type (number, string, etc)

                updatedConfig[key] = value
                updatedConfigs.append(ConfigSpec(dict: updatedConfig, yaml: config.yaml))
            } else {
                throw KeyError.missingValue(forKey: key) // TODO: Raise an exception
            }

        }

        return try expand(configs: updatedConfigs, keys: Array(keys.dropFirst()), as: type)
    }

}
