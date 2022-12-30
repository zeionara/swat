import Foundation

extension URL {
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    func appendingPathComponentIfNotNull(_ url: URL?) -> URL {
        if let url = url {
            return self.appendingPathComponent(url.path)
        }
        return self
    }

}
