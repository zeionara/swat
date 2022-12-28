import Yaml

extension String {
    var withoutPrefixMark: String {
        String(self.dropFirst(ConfigSpec.prefixMark.count + ConfigSpec.keySeparator.count))
    }
}

struct ConfigSpec {
    static let prefixMark = "__"
    static let keySeparator = "."

    let dict: [String: Any]
    let yaml: Yaml
    let keyPrefix: [String]

    init(dict: [String: Any], yaml: Yaml, keyPrefix: [String]? = nil) {
        self.dict = dict
        self.yaml = yaml
        self.keyPrefix = keyPrefix ?? [ConfigSpec.prefixMark]
    }

    subscript(key: String) -> ConfigSpec {
        // print("subscripting using key \(key), current prefix: \(keyPrefix)")
        return ConfigSpec(
            dict: (self.dict)[key]! as! [String: Any],
            yaml: self.yaml[.string(key)],
            keyPrefix: keyPrefix.appending(key)
        )
    }

    func hasAsIsMark(key: String) -> Bool {
        if case let .string(comment) = self.yaml[.string("__comment__\(key)")], comment.starts(with: "as-is") {
            return true
        }
        return false
    }

    func addPrefix(toKey key: String) -> String {
        return keyPrefix.appending(key).joined(separator: ConfigSpec.keySeparator)
    }

}
