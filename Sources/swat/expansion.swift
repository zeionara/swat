let DEFAULT_NAME_KEY = "name"

private func expand(config: ConfigSpec, name_key: String) -> [ConfigSpec] {
    return expand(dicts: [config], keys: config.dict.map{ $0.key }.sorted(), name_key: name_key)
}

private func expand(config: [String: Any], root: inout [String: Any], key: String, updatedConfigs: inout [ConfigSpec], spec: ConfigSpec, name_key: String) -> Void {
    for expandedNestedConfig in expand(config: ConfigSpec(dict: config, yaml: spec.yaml[.string(key)]), name_key: name_key) {
        root[key] = expandedNestedConfig
        updatedConfigs.append(ConfigSpec(dict: root, yaml: spec.yaml))
    }
}

private func expand(items: [Any], root: inout [String: Any], key: String, updatedConfigs: inout [ConfigSpec], spec: ConfigSpec, name_key: String) -> Void {
    let hasAsIsMark = spec.hasAsIsMark(key: key)

    if hasAsIsMark {
        root[key] = items
        updatedConfigs.append(ConfigSpec(dict: root, yaml: spec.yaml))
    }

    items.forEach{ (item) -> Void in
        if let nestedConfig = item as? [String: Any] {
            expand(config: nestedConfig, root: &root, key: key, updatedConfigs: &updatedConfigs, spec: spec, name_key: name_key)
        } else if !hasAsIsMark {
            root[key] = item
            updatedConfigs.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }
    }
}

private func expand(dicts configs: [ConfigSpec], keys: [String], name_key: String) -> [ConfigSpec] {
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
                expand(items: items, root: &updatedConfig, key: key, updatedConfigs: &updatedConfigs, spec: config, name_key: name_key)
                return
            }

            // expand object

            if let nestedConfig = value as? [String: Any] {
                expand(config: nestedConfig, root: &updatedConfig, key: key, updatedConfigs: &updatedConfigs, spec: config, name_key: name_key)
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

func expand(_ spec: ConfigSpec, name_key: String) -> [ConfigSpec] {
    return expand(config: spec, name_key: name_key)
}

func expand(_ spec: ConfigSpec) -> [ConfigSpec] {
    return expand(config: spec, name_key: DEFAULT_NAME_KEY)
}
