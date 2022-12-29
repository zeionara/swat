import Swat

struct ConfigWithNestedArrayOfExpandableObjects: ConfigWithDefaultKeys, RootConfig {
    let trivials: [SecondaryTrivialConfig]
    let qux: String

    let name: String
}
