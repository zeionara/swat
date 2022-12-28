import Foundation

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

    func camelCased(with separator: Character) -> String {
        // Implementation from https://stackoverflow.com/questions/48849452/swift-3-4-dash-to-camel-case-snake-to-camelcase
        return self.lowercased()
            .split(separator: separator)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
}
