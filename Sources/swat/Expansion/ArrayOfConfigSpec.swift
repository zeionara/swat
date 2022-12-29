extension Array where Element == ConfigSpec {

    mutating func append(expansionsOf root: inout [String: Any], on config: [String: Any], at key: String, spec: ConfigSpec, expander: Expander) throws -> Void {

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

    mutating func append(expansionsOf root: inout [String: Any], on items: [Any], at key: String, spec: ConfigSpec, expander: Expander) throws -> Void {

        if spec.hasAsIsMark(key: key) {
            root[key] = items
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            return
        }

        try items.forEach{ (item) -> Void in
            root[spec.addPrefix(toKey: key)] = item

            if let nestedConfig = item as? [String: Any] {
                try self.append(expansionsOf: &root, on: nestedConfig, at: key, spec: spec, expander: expander)
            } else {
                root[key] = item
                self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            }
        }

    }
}
