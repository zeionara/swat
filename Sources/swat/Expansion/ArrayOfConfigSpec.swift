enum YamlStructureError: Error {
    case mustBeArray
}
extension Array where Element == ConfigSpec {

    mutating func append(expansionsOf root: inout [String: Any], on config: [String: Any], at key: String, spec: ConfigSpec, expander: Expander, childAs type: Config.Type?) throws -> Void {

        if spec.hasAsIsMark(key: key) {
            root[key] = config
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            return
        }

        // print(spec, key)
        // print(spec.yaml[.string(key)])

        for expandedNestedConfig in try expander.expand(config: ConfigSpec(dict: config, yaml: spec.yaml[.string(key)], keyPrefix: spec.keyPrefix.appending(key)), as: type, isRecursiveCall: true) {
            root[key] = expandedNestedConfig
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }

    }

    mutating func append(expansionsOf root: inout [String: Any], on items: [Any], at key: String, spec: ConfigSpec, expander: Expander, as type: Config.Type?) throws -> Void {

        func appendConfigWithFixedList() throws {

            if case let .array(elements) = spec.yaml[.string(key)] {
                let configVariants: [[Any]] = try zip(items, elements).map{ item, element in
                    if let nestedConfig = item as? [String: Any] {
                        let spec = ConfigSpec(
                                    dict: nestedConfig,
                                    // yaml: spec.yaml[.string(key)],
                                    yaml: element,
                                    keyPrefix: spec.keyPrefix.appending(key)
                                )
                        // print("EXPANDING SPEC = ", spec)
                        return try expander.expand(
                            config: spec,
                            as: type?.type(of: key) as? Config.Type,
                            isRecursiveCall: true
                        )
                    } else {
                        return [item]
                    }
                }
                // print("STOP")

                // print(cartesianProduct([1, 2], [3, 4]))
                for items in cartesianProduct(configVariants) {
                    root[key] = items
                    self.append(ConfigSpec(dict: root, yaml: spec.yaml))  // TODO: implement deep expansion of elements inside such lists
                }
            } else {
                throw YamlStructureError.mustBeArray
            }
        }

        // print("LISTTTTTTTT", key, spec)
        if spec.hasAsIsMark(key: key) {
            try appendConfigWithFixedList()
            return
        } else if let _ = try type?.getElementTypeIfIsArray(property: key.fromKebabCase), !spec.hasExpandMark(key: key) {
            // TODO: Implement automatic inference of the expand label? (it is complicated because of lists may consist of many layers and contain objects of any type)
            // root[key] = items
            // self.append(ConfigSpec(dict: root, yaml: spec.yaml))  // TODO: implement deep expansion of elements inside such lists
            try appendConfigWithFixedList()
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
