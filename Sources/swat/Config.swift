import Foundation
import Runtime

public protocol RootConfig: Config {
    var name: String { get }
}

public protocol Config: Codable {
    static func decode(key: String) throws -> String
}

public extension Config {
    static func type(of propertyName: String) throws -> Any.Type {
        try typeInfo(of: Self.self).property(named: propertyName).type
    }

    static func getElementTypeIfIsArray(property propertyName: String) throws -> Any.Type? {
        let propertyTypeInfo = try type(of: try decode(key: propertyName))
        let propertyTypeTypeInfo = try typeInfo(of: propertyTypeInfo)

        if propertyTypeTypeInfo.mangledName == "Array" {
            return propertyTypeTypeInfo.genericTypes.first
        }

        return nil
    }
}

public enum ConfigSerializationFormat {
    case json
}

public enum ConfigSerializationError: Error {
    case formatIsNotSupported(format: ConfigSerializationFormat)
}

public extension RootConfig {

    func write(to path: URL, as format: ConfigSerializationFormat = .json, using keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws {
        var data: Data

        switch format {
            case .json:
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = keyEncodingStrategy
                data = try encoder.encode(self)
            // default:
            //     throw ConfigSerializationError.formatIsNotSupported(format: format)
        }

        try data.write(to: path)
    }

}
