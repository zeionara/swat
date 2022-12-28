struct Expander {
    var nameKey: String = "name"

    internal func expand(config: ConfigSpec) -> [[String: Any]] {
        return expand(configs: [config], keys: config.dict.map{ $0.key }.sorted()).map{ $0.dict }
    }

    internal func expand(configs: [ConfigSpec], keys: [String]) -> [ConfigSpec] {
        if configs.count < 1 {
            return configs
        }

        let key = keys.first!
        var updatedConfigs = [ConfigSpec]()

        configs.forEach { (config) -> Void in
            var updatedConfig = config.dict

            if let value = updatedConfig.removeValue(forKey: key) {

                // expand list

                if let items = value as? [Any] {
                    updatedConfigs.append(expansionsOf: &updatedConfig, on: items, at: key, spec: config, expander: self)
                    return
                }

                // expand object

                if let nestedConfig = value as? [String: Any] {
                    updatedConfigs.append(expansionsOf: &updatedConfig, on: nestedConfig, at: key, spec: config, expander: self)
                    return
                }

                // expand value of a basic type (number, string, etc)

                updatedConfig[key] = value
                updatedConfigs.append(ConfigSpec(dict: updatedConfig, yaml: config.yaml))
            } else {
                print("There is no key \(key) in dict") // TODO: Raise an exception
            }

        }

        return updatedConfigs
    }

}
