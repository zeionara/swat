import Runtime

public protocol Config: Decodable {
    var name: String { get }

    static func type(of: String) throws -> Any.Type
}

public extension Config {
    static func type(of propertyName: String) throws -> Any.Type {
        try typeInfo(of: Self.self).property(named: propertyName).type
        // return Int.self
    }
}
