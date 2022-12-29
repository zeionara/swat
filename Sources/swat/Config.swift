import Runtime

public protocol Config: Decodable {
    var name: String { get }

    // static func type(of: String) throws -> Any.Type
    static func decode(key: String) throws -> String
}

public extension Config {
    // static func decode(key: String) -> String {
    //     return key
    // }

    static func type(of propertyName: String) throws -> Any.Type {
        try typeInfo(of: Self.self).property(named: propertyName).type
    }

    static func getElementTypeIfIsArray(property propertyName: String) throws -> Any.Type? {
        // print(CodingKeys.self)
        // let info = try typeInfo(of: self)
        // print(info)
        // print(TrivialConfigWithCustomizedKeys.CondigKeys)

        let propertyTypeInfo = try type(of: try decode(key: propertyName))
        let propertyTypeTypeInfo = try typeInfo(of: propertyTypeInfo)
        if propertyTypeTypeInfo.mangledName == "Array" {
            return propertyTypeTypeInfo.genericTypes.first
        }
        return nil
    }
}
