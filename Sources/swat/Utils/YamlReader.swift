import Foundation
import Yaml

struct YamlReader: YamlReaderProtocol {
    var root: URL = Path.assets

    func read(_ content: String, in directory: URL? = Path.assets) throws -> Yaml {
        return try .dictionary(
            readReferencedFiles(
                from: Yaml.load(content, preserveComments: true).dictionary!,
                in: directory ?? root
            )
        )
    }

    private func handleValue(_ value: Yaml, in directory: URL) throws -> Yaml {
        if case let .string(stringifiedValue) = value {
            if Path.isYaml(stringifiedValue) {
                let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
                let nestedContent = try! self.read(from: stringifiedValue.fileName, in: nestedPath)

                return try! .dictionary(readReferencedFiles(from: nestedContent.dictionary!, in: nestedPath))
            }

            if let folderPath = Path.getFolderPath(stringifiedValue) {
                return try! readReferencedFiles(in: directory.appendingPathComponent(folderPath))
            }
        }

        if case let .dictionary(content) = value {
            return try! .dictionary(readReferencedFiles(from: content, in: directory))
        }

        return value
    }

    private func readReferencedFiles(in directory: URL) throws -> Yaml {
        var result = [Yaml]()

        for url in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
            let path = url.path

            if url.isDirectory {
                result.append(try! readReferencedFiles(in: url))
            } else {
                result.append(try! read(from: path.fileName, in: path.folderPath))
            }
        }

        return .array(result)
    }

    private func readReferencedFiles(from content: [Yaml: Yaml], in directory: URL) throws -> [Yaml: Yaml] {
        var result = [Yaml: Yaml]()

        for (key, value) in content {
            if case let .array(items) = value {
                result[key] = .array(
                    items.map { (item) -> Yaml in
                        try! handleValue(item, in: directory)
                    }
                )
            } else {
                result[key] = try! handleValue(value, in: directory)
            }
        }

        return result
    }
}
