import Swat
import Runtime

struct TrivialConfigWithCustomizedKeys: ConfigWithCustomizedKeys {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case qux = "foo", quux = "bar", name
    }

    let qux: Int
    let quux: String

    let name: String
}
