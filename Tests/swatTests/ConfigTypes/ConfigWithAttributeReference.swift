import Swat

struct ConfigWithAttributeReference: ConfigWithDefaultKeys, RootConfig {
    let foo: String
    let bar: String

    let name: String
}
