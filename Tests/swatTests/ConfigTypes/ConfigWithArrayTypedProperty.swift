import Swat

struct ConfigWithArrayTypedProperty: Config {
    // enum Keys: String, Decodable {
    //     case foo, bar
    // }

    let foo: Int
    let bar: String
    let baz: Array<Int>

    let name: String

    static func decode(key: String) throws -> String {
        return key
    }
}
