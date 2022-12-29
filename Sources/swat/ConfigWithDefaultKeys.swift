public protocol ConfigWithDefaultKeys: Config {}

public extension ConfigWithDefaultKeys {
    static func decode(key: String) throws -> String {
        return key
    }
}
