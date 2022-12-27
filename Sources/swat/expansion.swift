let DEFAULT_NAME_KEY = "name"

private func expand(config: [String: Any], name_key: String) -> [[String: Any]] {
    return expand(dicts: [config], keys: config.map{ $0.key }, name_key: name_key)
}

private func expand(config: [String: Any], root: inout [String: Any], key: String, updatedConfigs: inout [[String: Any]], name_key: String) -> Void {
    for expandedNestedConfig in expand(config: config, name_key: name_key) {
        root[key] = expandedNestedConfig
        updatedConfigs.append(root)
        // print("updating config...")
        // print(updatedConfigs)
    }
}

private func expand(items: [Any], root: inout [String: Any], key: String, updatedConfigs: inout [[String: Any]], name_key: String) -> Void {
    items.forEach{ (item) -> Void in
        if let nestedConfig = item as? [String: Any] {
            expand(config: nestedConfig, root: &root, key: key, updatedConfigs: &updatedConfigs, name_key: name_key)
        } else {
            root[key] = item
            updatedConfigs.append(root)
        }
    }
}

private func expand(dicts configs: [[String: Any]], keys: [String], name_key: String) -> [[String: Any]] {
    if configs.count < 1 {
        return configs
    }

    let key = keys.first!
    var updatedConfigs = [[String: Any]]()

    configs.forEach { (config) -> Void in
        var updatedConfig = config

        if let value = updatedConfig.removeValue(forKey: key) {

            // expand list

            // print("start processing list \(value)...")
            if let items = value as? [Any] {
                expand(items: items, root: &updatedConfig, key: key, updatedConfigs: &updatedConfigs, name_key: name_key)
                return
                // items.forEach{ (item) -> Void in
                //     if let nestedConfig = item as? [String: Any] {
                //         for expandedNestedConfig in expand(dict: nestedConfig, name_key: name_key) {
                //             updatedConfig[key] = expandedNestedConfig
                //             updatedConfigs.append(updatedConfig)
                //         }
                //     } else {
                //         updatedConfig[key] = item
                //         updatedConfigs.append(updatedConfig)
                //     }
                // }
            }
            // print(updatedConfigs)
            // print("stop processing list \(value)")

            // expand object and basic values (number, string, etc)

            if let nestedConfig = value as? [String: Any] {
                expand(config: nestedConfig, root: &updatedConfig, key: key, updatedConfigs: &updatedConfigs, name_key: name_key)
                return
                // for expandedNestedConfig in expand(dict: nestedConfig, name_key: name_key) {
                //     updatedConfig[key] = expandedNestedConfig
                //     updatedConfigs.append(updatedConfig)
                // }
            }

            updatedConfig[key] = value
            updatedConfigs.append(updatedConfig)
        } else {
            print("There is no key \(key) in dict") // TODO: Raise an exception
        }

    }

    return updatedConfigs
}

func expand(_ config: [String: Any], name_key: String = DEFAULT_NAME_KEY) -> [[String: Any]] {
    return expand(config: config, name_key: name_key)
    // return expand(configs: [config], keys: config.map{ $0.key }, name_key: name_key)
}
