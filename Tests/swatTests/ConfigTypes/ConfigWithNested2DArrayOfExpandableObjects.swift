import Swat

struct ConfigWithNested2DArrayOfExpandableObjects: ConfigWithDefaultKeys, RootConfig {
    let trivials: [[SecondaryTrivialConfig]]
    let qux: String

    let name: String
}
