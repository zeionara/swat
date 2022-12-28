import Foundation

struct ConfigSpecReader: YamlReaderProtocol {
    let root: URL

    let yamlReader: YamlReader
    let yamsReader: YamsReader

    init(at root: URL = Path.assets) {
        self.root = root

        yamlReader = YamlReader(root: root)
        yamsReader = YamsReader(root: root)
    }

    func read(_ content: String, in directory: URL? = nil) throws -> ConfigSpec {
        let dict = try yamsReader.read(content, in: directory)
        let yaml = try yamlReader.read(content, in: directory)

        return ConfigSpec(dict: dict, yaml: yaml)
    }
}
