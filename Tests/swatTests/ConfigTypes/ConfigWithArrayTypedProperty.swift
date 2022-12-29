import Swat

struct ConfigWithArrayTypedProperty: ConfigWithDefaultKeys {
    let foo: Int
    let bar: String
    let baz: Array<Int>

    let name: String
}
