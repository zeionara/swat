import Foundation
import Yaml

protocol Reader {
    associatedtype ResultType
    associatedtype Key: Hashable
    associatedtype Value

    var root: URL { get }

    func parse(_ content: String) -> [Key: Value]
    func toResultType(_ content: [Key: Value]) -> ResultType
    func readReferencedFiles(key: Key, value: Value, result: inout [Key: Value], in directory: URL?) -> Void
    func toDict(_ content: ResultType) -> [Key: Value]?
    func toString(_ content: ResultType) -> String?
    func toResultType(_ content: [ResultType]) -> ResultType

    func read(from path: String, in directory: URL?) throws -> ResultType
    func read(_ content: String, in directory: URL?) throws -> ResultType

    func readReferencedFiles(from content: [Key: Value], in directory: URL?) throws -> [Key: Value]
    func readReferencedFiles(in directory: URL) throws -> [ResultType]
}

extension Reader {
    func read(from path: String, in directory: URL? = nil) throws -> ResultType {
        let unwrappedDirectory = directory ?? root
        let fileContent = try String(contentsOf: unwrappedDirectory.appendingPathComponent(path), encoding: .utf8)
        return try self.read(fileContent, in: unwrappedDirectory)
    }

    func read(_ content: String, in directory: URL? = nil) throws -> ResultType {
        return try toResultType(
            readReferencedFiles(
                from: parse(content),
                in: directory ?? root
            )
        )
    }

    internal func readReferencedFiles(from content: [Key: Value], in directory: URL? = nil) throws -> [Key: Value] {
        var result = [Key: Value]()

        for (key, value) in content {
            readReferencedFiles(key: key, value: value, result: &result, in: directory ?? root)
        }

        return result
    }

    internal func readReferencedFiles(in directory: URL) throws -> [ResultType] {
        var result = [ResultType]()

        for url in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
            let path = url.path

            if url.isDirectory {
                result.append(toResultType(try! readReferencedFiles(in: url)))
            } else {
                result.append(try! read(from: path.fileName, in: path.folderPath))
            }
        }

        return result
    }

    internal func handleValue(_ value: ResultType, in directory: URL) throws -> ResultType {
        if let stringifiedValue = toString(value) {
            if Path.isYaml(stringifiedValue) {
                let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
                let nestedContent = try! self.read(from: stringifiedValue.fileName, in: nestedPath)

                return try! toResultType(readReferencedFiles(from: toDict(nestedContent)!, in: nestedPath))
            }

            if let folderPath = Path.getFolderPath(stringifiedValue) {
                return try! toResultType(readReferencedFiles(in: directory.appendingPathComponent(folderPath)))
            }
        }

        if let content = toDict(value) {
            return try! toResultType(readReferencedFiles(from: content, in: directory))
        }

        return value
    }
}

struct YamlReader: Reader {
    let root: URL

    func parse(_ content: String) -> [Yaml: Yaml] {
        return try! Yaml.load(content, preserveComments: true).dictionary!
    }

    func toResultType(_ content: [Yaml: Yaml]) -> Yaml {
        return .dictionary(content)
    }

    func toResultType(_ content: [ResultType]) -> ResultType {
        return .array(content)
    }

    func readReferencedFiles(key: Yaml, value: Yaml, result: inout [Yaml: Yaml], in directory: URL?) -> Void {
        if case let .array(items) = value {
            result[key] = .array(
                items.map { (item) -> Yaml in
                    try! handleValue(item, in: directory ?? root)
                }
            )
        } else {
            result[key] = try! handleValue(value, in: directory ?? root)
        }
    }

    func toDict(_ content: Yaml) -> [Yaml: Yaml]? {
        if case let .dictionary(value) = content {
            return value
        }
        return nil
    }

    func toString(_ content: Yaml) -> String? {
        if case let .string(value) = content {
            return value
        }
        return nil
    }

    func read(from path: String, in directory: URL? = nil) throws -> Yaml {
        let unwrappedDirectory = directory ?? root
        let fileContent = try String(contentsOf: unwrappedDirectory.appendingPathComponent(path), encoding: .utf8)
        return try read(fileContent, in: unwrappedDirectory)
    }

    func read(_ content: String, in directory: URL? = nil) throws -> Yaml {
        return try .dictionary(
            readReferencedFiles(
                from: Yaml.load(content, preserveComments: true).dictionary!,
                in: directory ?? root
            )
        )
    }

    // private func handleValue(_ value: Yaml, in directory: URL) throws -> Yaml {
    //     if case let .string(stringifiedValue) = value {
    //         if Path.isYaml(stringifiedValue) {
    //             let nestedPath = directory.appendingPathComponent(stringifiedValue.folderPath.relativePath)
    //             let nestedContent = try! self.read(from: stringifiedValue.fileName, in: nestedPath)

    //             return try! .dictionary(readReferencedFiles(from: nestedContent.dictionary!, in: nestedPath))
    //         }

    //         if let folderPath = Path.getFolderPath(stringifiedValue) {
    //             return try! readReferencedFiles(in: directory.appendingPathComponent(folderPath))
    //         }
    //     }

    //     if case let .dictionary(content) = value {
    //         return try! .dictionary(readReferencedFiles(from: content, in: directory))
    //     }

    //     return value
    // }

    // private func readReferencedFiles(in directory: URL) throws -> Yaml {
    //     var result = [Yaml]()

    //     for url in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
    //         let path = url.path

    //         if url.isDirectory {
    //             result.append(try! readReferencedFiles(in: url))
    //         } else {
    //             result.append(try! read(from: path.fileName, in: path.folderPath))
    //         }
    //     }

    //     return .array(result)
    // }

    // private func readReferencedFiles(from content: [Yaml: Yaml], in directory: URL? = nil) throws -> [Yaml: Yaml] {
    //     var result = [Yaml: Yaml]()

    //     for (key, value) in content {
    //         if case let .array(items) = value {
    //             result[key] = .array(
    //                 items.map { (item) -> Yaml in
    //                     try! handleValue(item, in: directory ?? root)
    //                 }
    //             )
    //         } else {
    //             result[key] = try! handleValue(value, in: directory ?? root)
    //         }
    //     }

    //     return result
    // }
}
