import Foundation

public struct Path {
    static let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    static public let assets = Path.root.appendingPathComponent("Assets")
    static let testAssets = Path.assets.appendingPathComponent("Test")

    static private let yamlRegex = try! NSRegularExpression(pattern: ".+\\.ya?ml$")
    static private let folderRegex = try! NSRegularExpression(pattern: "@(?<path>.+)")

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
