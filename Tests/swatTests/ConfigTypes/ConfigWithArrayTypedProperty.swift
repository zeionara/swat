import Swat

struct ConfigWithArrayTypedProperty: ConfigWithDefaultKeys, RootConfig {
    let foo: Int
    let bar: String
    let baz: Array<Int>

    let name: String
}
