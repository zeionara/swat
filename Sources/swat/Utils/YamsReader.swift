import Foundation
import Yams

struct YamsReader: YamlReaderProtocol {
    let root: URL

    func read(_ content: String, in directory: URL? = Path.assets) throws -> [String: Any] {
        return try readReferencedFiles(
            from: Yams.load(yaml: content) as! [String: Any],
            in: directory ?? root
        )
    }

    private func handleValue(_ value: Any, in directory: URL) throws -> Any {
        if let stringifiedValue = value as? String {
            if Path.isYaml(stringifiedValue) {
                let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
                let nestedContent = try! read(from: stringifiedValue.fileName, in: nestedPath)

                return try! readReferencedFiles(from: nestedContent, in: nestedPath)
            }

            if let folderPath = Path.getFolderPath(stringifiedValue) {
                return try! readReferencedFiles(in: directory.appendingPathComponent(folderPath))
            }
        }

        if let nestedContent = value as? [String: Any] {
            return try! readReferencedFiles(from: nestedContent, in: directory)
        }

        return value
    }

    private func readReferencedFiles(in directory: URL) throws -> [Any] {
        var result = [Any]()

        for url in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
            let path = url.path

            if url.isDirectory {
                result.append(try! readReferencedFiles(in: url))
            } else {
                result.append(try! read(from: path.fileName, in: path.folderPath))
            }
        }

        return result
    }

    private func readReferencedFiles(from content: [String: Any], in directory: URL) throws -> [String: Any] {
        var result = [String: Any]()

        for (key, value) in content {
            if let items = value as? [Any] {
                result[key] = items.map { (item) -> Any in
                    try! handleValue(item, in: directory)
                }
            } else {
                result[key] = try! handleValue(value, in: directory)
            }
        }

        return result
    }
}
