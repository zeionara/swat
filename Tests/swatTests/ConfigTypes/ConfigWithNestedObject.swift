import Swat

struct Foo: ConfigWithDefaultKeys {
    let foo: Int
    let bar: String
}

struct ConfigWithNestedObject: ConfigWithDefaultKeys, RootConfig {
    let trivial: Foo
    let qux: String

    let name: String
}
