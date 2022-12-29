import Swat

struct MultiwordConfig: Config {
    // enum Keys: String, CodingKey {
    //     case fooBar, barBaz
    // }

    let fooBar: Int
    let barBaz: String

    let name: String

    static func decode(key: String) throws -> String {
        return key
    }
}
