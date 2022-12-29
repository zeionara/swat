import Swat

struct SecondaryTrivialConfig: ConfigWithDefaultKeys {
    let foo: Int
    let bar: String
}

struct ConfigWithNestedObject: ConfigWithDefaultKeys, RootConfig {
    let trivial: SecondaryTrivialConfig
    let qux: String

    let name: String
}
