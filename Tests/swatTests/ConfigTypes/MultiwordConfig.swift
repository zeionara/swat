import Swat

struct MultiwordConfig: Config {
    let fooBar: Int
    let barBaz: String

    let name: String

    static func decode(key: String) throws -> String {
        return key
    }
}
