import Foundation

struct ConfigFactory {
    public static let defaultFileName = "default.yml"

    enum ConfigMakingError: Error {
        case invalidNumberOfElements(count: Int)
    }

    let root: URL
    let reader: ConfigSpecReader
    let expander: Expander

    init(at root: URL = Path.assets) {
        self.root = root
        reader = ConfigSpecReader(at: root)
        expander = Expander()
    }

    func make<T>(from fileName: String, in directory: URL? = nil) throws -> [T] where T: Decodable {

        let configs = try reader.read(from: fileName, in: root.appendingPathComponentIfNotNull(directory)) |> expander.expand(as: T.self)
        //print(configs)
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .custom { keys in
            let lastComponent = keys.last!.stringValue
            return AnyKey(stringValue: lastComponent.fromKebabCase)
        }

        return try configs.map {
            return try decoder.decode(
                T.self,
                from: try JSONSerialization.data(withJSONObject: $0)
            )
        }
    }

    func make<T>(in directory: URL? = nil) throws -> [T] where T: Decodable {
        return try make(from: ConfigFactory.defaultFileName, in: directory)
    }

    func makeOne<T>(from fileName: String, in directory: URL? = nil) throws -> T where T: Decodable {
        let results: [T] = try make(from: fileName, in: directory)

        guard results.count == 1 else {
            throw ConfigMakingError.invalidNumberOfElements(count: results.count)
        }

        return results.first!
    }

    func makeOne<T>(in directory: URL? = nil) throws -> T where T: Decodable {
        let results: [T] = try make(in: directory)

        guard results.count == 1 else {
            throw ConfigMakingError.invalidNumberOfElements(count: results.count)
        }

        return results.first!
    }
}
