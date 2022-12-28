import Foundation

protocol YamlReaderProtocol {
    associatedtype ResultType

    var root: URL { get }

    func read(from path: String, in directory: URL?) throws -> ResultType
    func read(_ content: String, in directory: URL?) throws -> ResultType
}

extension YamlReaderProtocol {
    func read(from path: String, in directory: URL? = nil) throws -> ResultType {
        let unwrappedDirectory = directory ?? root
        let fileContent = try String(contentsOf: unwrappedDirectory.appendingPathComponent(path), encoding: .utf8)
        return try self.read(fileContent, in: unwrappedDirectory)
    }
}
