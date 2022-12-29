import Swat

struct MultiwordConfig: ConfigWithDefaultKeys, RootConfig {
    let fooBar: Int
    let barBaz: String

    let name: String
}
