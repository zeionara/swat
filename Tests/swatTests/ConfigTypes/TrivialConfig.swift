import Swat

struct TrivialConfig: Config {
    // enum Keys: String, Decodable {
    //     case foo, bar
    // }

    let foo: Int
    let bar: String

    let name: String

    static func decode(key: String) throws -> String {
        return key
    }
}
