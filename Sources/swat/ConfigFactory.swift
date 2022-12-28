import Foundation

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

struct ConfigFactory {
    let root: URL
    let reader: ConfigSpecReader
    let expander: Expander

    init(at root: URL = Path.assets) {
        self.root = root
        reader = ConfigSpecReader(at: root)
        expander = Expander()
    }

    func make<T>(from fileName: String, in directory: URL? = nil) throws -> [T] where T: Decodable {
        // var configs: [[String: Any]]

        let configs = try! reader.read(from: fileName, in: root.appendingPathComponentIfNotNull(directory)) |> expander.expand

        // if let directory = directory {
        //     configs = (try! reader.read(from: fileName, in: root.appendingPathComponentIfNotNull(directory)) |> expander.expand)
        // } else {
        //     configs = (try! reader.read(from: fileName, in: root) |> expander.expand)
        // }

        return try configs.map {
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy = .custom { keys in
                let lastComponent = keys.last!.stringValue
                return AnyKey(stringValue: lastComponent.camelCased(with: "-"))
            }

            return try decoder.decode(
                T.self,
                from: try JSONSerialization.data(withJSONObject: $0)
            )
        }
    }

    func make<T>(in directory: URL? = nil) throws -> [T] where T: Decodable {
        return try make(from: "default.yml", in: directory)
    }
}
