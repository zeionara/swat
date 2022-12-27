import Foundation
import Yams

struct Path {
    static let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    static let assets = Path.root.appendingPathComponent("Assets")
    static let testAssets = Path.assets.appendingPathComponent("Test")
}

extension String {
    var url: URL {
        return URL(fileURLWithPath: self)
    }

    var fileName: String {
        return self.url.lastPathComponent
    }

    var folderPath: URL {
        return self.url.deletingLastPathComponent()
    }
}

func isYamlFilePath(_ path: String) -> Bool {
    let range = NSRange(location: 0, length: path.count)
    let regex = try! NSRegularExpression(pattern: ".+\\.yml$")
    return regex.firstMatch(in: path, options: [], range: range) != nil
}

func handleValue(_ value: Any, in directory: URL = Path.assets) throws -> Any {
    if let stringifiedValue = value as? String, isYamlFilePath(stringifiedValue) {
        let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
        let nestedContent = try! read(from: stringifiedValue.fileName, in: nestedPath)

        return try! readReferencedFiles(from: nestedContent, in: nestedPath)
    }

    if let nestedContent = value as? [String: Any] {
        return try! readReferencedFiles(from: nestedContent, in: directory)
    }

    return value
}

func readReferencedFiles(from content: [String: Any], in directory: URL = Path.assets) throws -> [String: Any] {
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

func read(from path: String, in directory: URL = Path.assets) throws -> [String: Any] {
    let fileContent = try String(contentsOf: directory.appendingPathComponent(path), encoding: .utf8)

    return try readReferencedFiles(
        from: Yams.load(yaml: fileContent) as! [String: Any],
        in: directory
    )
}
