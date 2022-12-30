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

        for expandedNestedConfig in try expander.expand(config: ConfigSpec(dict: config, yaml: spec.yaml[.string(key)], keyPrefix: spec.keyPrefix.appending(key)), as: type, isRecursiveCall: true) {
            root[key] = expandedNestedConfig
            self.append(ConfigSpec(dict: root, yaml: spec.yaml))
        }

    }

    mutating func append(expansionsOf root: inout [String: Any], on items: [Any], at key: String, spec: ConfigSpec, expander: Expander, as configType: Config.Type?) throws -> Void {

        func appendConfigWithFixedList() throws {

            if case let .array(elements) = spec.yaml[.string(key)] {  // Each element of spec may contain nested # as-is and # expand marks
                let configVariants: [[Any]] = try zip(items, elements).map{ item, element in
                    if let nestedConfig = item as? [String: Any] {
                        return try expander.expand(
                            config: ConfigSpec(dict: nestedConfig, yaml: element, keyPrefix: spec.keyPrefix.appending(key)),
                            as: configType?.type(of: key) as? Config.Type,
                            isRecursiveCall: true
                        )
                    } else {
                        return [item]
                    }
                }

                for items in cartesianProduct(configVariants) {
                    root[key] = items
                    self.append(ConfigSpec(dict: root, yaml: spec.yaml))
                }
            } else {
                throw YamlStructureError.mustBeArray
            }
        }

        if spec.hasAsIsMark(key: key) {
            try appendConfigWithFixedList()
            return
        } else if let _ = try configType?.getElementTypeIfIsArray(property: key.fromKebabCase), !spec.hasExpandMark(key: key) {
            // TODO: Implement automatic inference of the expand label? (it is complicated because of lists may consist of many layers and contain objects of any type)
            try appendConfigWithFixedList()
            return
        }

        // if let _ = try configType?.getElementTypeIfIsArray(property: key.fromKebabCase) {
        //     // print(typeInfo(of: type(of: items)))

        //     // print(type)
        //     print(type(of: items))
        //     if let foo = try configType?.type(of: try configType!.decode(key: key)) {
        //         print(items as? foo.Type)
        //     }
        //     // print(propertyTypeInfo)
        //     // print(type(of: items))
        // }

        try items.forEach{ (item) -> Void in
            root[spec.addPrefix(toKey: key)] = item

            if let nestedConfig = item as? [String: Any] {
                try self.append(expansionsOf: &root, on: nestedConfig, at: key, spec: spec, expander: expander, childAs: configType?.type(of: key) as? Config.Type)
            } else {
                root[key] = item
                self.append(ConfigSpec(dict: root, yaml: spec.yaml))
            }
        }
    }

}
