import Foundation

struct ConfigFactory {
    let root: URL
    let reader: ConfigSpecReader
    let expander: Expander

    init(at root: URL = Path.assets) {
        self.root = root
        reader = ConfigSpecReader(at: root)
        expander = Expander()
    }

    func make(from fileName: String, in directory: URL? = nil) {
        // var configs: [[String: Any]]

        let configs = try! reader.read(from: fileName, in: root.appendingPathComponentIfNotNull(directory)) |> expander.expand

        // if let directory = directory {
        //     configs = (try! reader.read(from: fileName, in: root.appendingPathComponentIfNotNull(directory)) |> expander.expand)
        // } else {
        //     configs = (try! reader.read(from: fileName, in: root) |> expander.expand)
        // }

        print(configs)
    }

    func make(in directory: URL? = nil) {
        return make(from: "default.yml", in: directory)
    }
}
