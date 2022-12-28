import Yaml

struct ConfigSpec {
    let dict: [String: Any]
    let yaml: Yaml

    init(dict: [String: Any], yaml: Yaml) {
        self.dict = dict
        self.yaml = yaml
    }

    subscript(key: String) -> ConfigSpec {
        return ConfigSpec(
            dict: (self.dict)[key]! as! [String: Any],
            yaml: self.yaml[.string(key)]
        )
    }

    func hasAsIsMark(key: String) -> Bool {
        if case let .string(comment) = self.yaml[.string("__comment__\(key)")], comment.starts(with: "as-is") {
            return true
        }
        return false
    }
}
