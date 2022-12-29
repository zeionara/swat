import Swat

struct TrivialConfig: Config {
    let foo: Int
    let bar: String

    let name: String

    static func decode(key: String) throws -> String {
        return key
    }
}
