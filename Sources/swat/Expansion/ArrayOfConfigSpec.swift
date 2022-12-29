extension Array where Element == ConfigSpec {

    mutating func append(expansionsOf root: inout [String: Any], on config: [String: Any], at key: String, spec: ConfigSpec, expander: Expander, childAs type: Config.Type?) throws -> Void {

        if spec.hasAsIsMark(key: key) {
            root[key] = config
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            return
        }

        for expandedNestedConfig in try expander.expand(config: ConfigSpec(dict: config, yaml: spec.yaml[.string(key)], keyPrefix: spec.keyPrefix.appending(key)), as: type, isRecursiveCall: true) {
            root[key] = expandedNestedConfig
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }

    }

    mutating func append(expansionsOf root: inout [String: Any], on items: [Any], at key: String, spec: ConfigSpec, expander: Expander, as type: Config.Type?) throws -> Void {

        if spec.hasAsIsMark(key: key) {
            root[key] = items
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))  // TODO: implement deep expansion of elements inside such lists
            return
        } else if let _ = try type?.getElementTypeIfIsArray(property: key.fromKebabCase), !spec.hasExpandMark(key: key) {
            root[key] = items
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))  // TODO: implement deep expansion of elements inside such lists
            return
        }

        try items.forEach{ (item) -> Void in
            root[spec.addPrefix(toKey: key)] = item

            if let nestedConfig = item as? [String: Any] {
                try self.append(expansionsOf: &root, on: nestedConfig, at: key, spec: spec, expander: expander, childAs: type?.type(of: key) as? Config.Type)
            } else {
                root[key] = item
                self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            }
        }
    }

}
