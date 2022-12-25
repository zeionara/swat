import Foundation
import Yams

struct Path {
    static let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    static let assets = Path.root.appendingPathComponent("Assets")
    static let testAssets = Path.assets.appendingPathComponent("Test")
}

func read(from path: String, in directory: URL = Path.assets) throws -> [String: Any] {
    // print(Path.testAssets.appendingPathComponent("singleFile.yml"))
    let fileContent = try String(contentsOf: directory.appendingPathComponent(path), encoding: .utf8)

    return try Yams.load(yaml: fileContent) as! [String: Any]
    // return decoded
    // print(content)
    // if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    //     print(dir)
    // }
    // let decoder = YAMLDecoder()
    // let decoded = try decoder.decode(Map<String, String>, from: "foo: bar")
    // print(NSDictionary(decoded).isEqualToDictionary(["foo": ["bar": ["baz": ["qux", "quux"]]])
    // print(NSDictionary(dictionary: decoded).isEqual(to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]))
    // return path;
}
