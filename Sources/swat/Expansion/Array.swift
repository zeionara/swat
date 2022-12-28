extension Array where Element == ConfigSpec {

    mutating func append(expansionsOf root: inout [String: Any], on config: [String: Any], at key: String, spec: ConfigSpec, expander: Expander) throws -> Void {
        for expandedNestedConfig in try expander.expand(config: ConfigSpec(dict: config, yaml: spec.yaml[.string(key)])) {
            root[key] = expandedNestedConfig
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }
    }

    mutating func append(expansionsOf root: inout [String: Any], on items: [Any], at key: String, spec: ConfigSpec, expander: Expander) throws -> Void {
        let hasAsIsMark = spec.hasAsIsMark(key: key)

        if hasAsIsMark {
            root[key] = items
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }

        try items.forEach{ (item) -> Void in
            if let nestedConfig = item as? [String: Any] {
                // expand(config: nestedConfig, root: &root, key: key, updatedConfigs: &updatedConfigs, spec: spec, name_key: name_key)
                try self.append(expansionsOf: &root, on: nestedConfig, at: key, spec: spec, expander: expander)
            } else if !hasAsIsMark {
                root[key] = item
                self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            }
        }
    }
}
