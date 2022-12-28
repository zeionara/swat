import Swat

struct TrivialConfigWithCustomizedKeys: Config {
    enum CodingKeys: String, CodingKey {
        case qux = "foo", quux = "bar", name
    }

    let qux: Int
    let quux: String

    let name: String
}
