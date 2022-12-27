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
}
