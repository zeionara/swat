import Swat

struct TrivialConfig: ConfigWithDefaultKeys, RootConfig {
    let foo: Int
    let bar: String

    let name: String
}
