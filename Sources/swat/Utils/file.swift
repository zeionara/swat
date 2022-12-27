import Foundation
import Yams
import Yaml

private func handleValue(_ value: Any, in directory: URL) throws -> Any {
    if let stringifiedValue = value as? String {
        if Path.isYaml(stringifiedValue) {
            let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
            let nestedContent = try! read(from: stringifiedValue.fileName, in: nestedPath).dict as! [String: Any]

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

private func handleValue(_ value: Yaml, in directory: URL) throws -> Yaml {
    if case let .string(stringifiedValue) = value {
        if Path.isYaml(stringifiedValue) {
            let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
            let nestedContent = try! readYaml(from: stringifiedValue.fileName, in: nestedPath)

            return try! .dictionary(readReferencedFilesYaml(from: nestedContent.dictionary!, in: nestedPath))
        }

        if let folderPath = Path.getFolderPath(stringifiedValue) {
            return try! readReferencedFilesYaml(in: directory.appendingPathComponent(folderPath))
        }
    }

    if case let .dictionary(content) = value {
        return try! .dictionary(readReferencedFilesYaml(from: content, in: directory))
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

private func readReferencedFilesYaml(from content: [Yaml: Yaml], in directory: URL) throws -> [Yaml: Yaml] {
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

private func readReferencedFiles(in directory: URL) throws -> [Any] {
    var result = [Any]()

    for url in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
        let path = url.path

        if url.isDirectory {
            result.append(try! readReferencedFiles(in: url))
        } else {
            result.append(try! read(from: path.fileName, in: path.folderPath).dict)
        }
    }

    return result
}

private func readReferencedFilesYaml(in directory: URL) throws -> Yaml {
    var result = [Yaml]()

    for url in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
        let path = url.path

        if url.isDirectory {
            result.append(try! readReferencedFilesYaml(in: url))
        } else {
            result.append(try! readYaml(from: path.fileName, in: path.folderPath))
        }
    }

    return .array(result)
}

func read(from path: String, in directory: URL = Path.assets) throws -> ConfigSpec {
    let fileContent = try String(contentsOf: directory.appendingPathComponent(path), encoding: .utf8)
    return try read(fileContent, in: directory)
}

func readYaml(from path: String, in directory: URL = Path.assets) throws -> Yaml {
    let fileContent = try String(contentsOf: directory.appendingPathComponent(path), encoding: .utf8)
    return try readYaml(fileContent, in: directory)
}

func read(_ content: String, in directory: URL = Path.assets) throws -> ConfigSpec {
    let dictContent = try readReferencedFiles(
        from: Yams.load(yaml: content) as! [String: Any],
        in: directory
    )

    return ConfigSpec(dict: dictContent, yaml: try readYaml(content, in: directory))
}

func readYaml(_ content: String, in directory: URL = Path.assets) throws -> Yaml {
    return try .dictionary(readReferencedFilesYaml(
        from: Yaml.load(content, preserveComments: true).dictionary!,
        in: directory
    ))
}
