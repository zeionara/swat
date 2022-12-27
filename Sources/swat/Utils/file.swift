import Foundation
import Yams

struct Path {
    static let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    static let assets = Path.root.appendingPathComponent("Assets")
    static let testAssets = Path.assets.appendingPathComponent("Test")

    static let yamlRegex = try! NSRegularExpression(pattern: ".+\\.ya?ml$")
    static let folderRegex = try! NSRegularExpression(pattern: "@(?<path>.+)")

    static func isYaml(_ path: String) -> Bool {
        let range = NSRange(location: 0, length: path.count)
        return Path.yamlRegex.firstMatch(in: path, options: [], range: range) != nil
    }

    static func getFolderPath(_ path: String) -> String? {
        let range = NSRange(location: 0, length: path.count)

        if let match = Path.folderRegex.firstMatch(in: path, range: range) {
            let pathRange = match.range(withName: "path")

            if let range = Range(pathRange, in: path) {
                return String(path[range])
            }
        }

        return nil
    }
}

extension URL {
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
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

func read(from path: String, in directory: URL = Path.assets) throws -> [String: Any] {
    let fileContent = try String(contentsOf: directory.appendingPathComponent(path), encoding: .utf8)

    return try readReferencedFiles(
        from: Yams.load(yaml: fileContent) as! [String: Any],
        in: directory
    )
}

func read(_ content: String, in directory: URL = Path.assets) throws -> [String: Any] {
    return try readReferencedFiles(
        from: Yams.load(yaml: content) as! [String: Any],
        in: directory
    )
}
