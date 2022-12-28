extension Array where Element == ConfigSpec {

    mutating func append(expansionsOf root: inout [String: Any], on config: [String: Any], at key: String, spec: ConfigSpec, expander: Expander, name: inout [String: Any]) throws -> Void {
        if spec.hasAsIsMark(key: key) {
            root[key] = config
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            return
        }

        for expandedNestedConfig in try expander.expand(config: ConfigSpec(dict: config, yaml: spec.yaml[.string(key)], keyPrefix: spec.keyPrefix.appending(key)), isRecursiveCall: true) {
            root[key] = expandedNestedConfig
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }
    }

    mutating func append(expansionsOf root: inout [String: Any], on items: [Any], at key: String, spec: ConfigSpec, expander: Expander, name: inout [String: Any]) throws -> Void {
        // let hasAsIsMark = spec.hasAsIsMark(key: key)

        // if hasAsIsMark {
        if spec.hasAsIsMark(key: key) {
            root[key] = items
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            return
        }

        try items.forEach{ (item) -> Void in
            // name[spec.addPrefix(toKey: key)] = item
            root[spec.addPrefix(toKey: key)] = item
            // print(spec)

            if let nestedConfig = item as? [String: Any] {
                // expand(config: nestedConfig, root: &root, key: key, updatedConfigs: &updatedConfigs, spec: spec, name_key: name_key)
                try self.append(expansionsOf: &root, on: nestedConfig, at: key, spec: spec, expander: expander, name: &name)
            // } else if !hasAsIsMark {
            } else {
                root[key] = item
                self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            }
        }
    }
}
