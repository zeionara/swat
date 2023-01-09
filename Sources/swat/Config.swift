import Foundation
import Runtime
import Yams

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
    case yaml
}

public enum ConfigSerializationError: Error {
    case formatIsNotSupported(format: ConfigSerializationFormat)
    case keyEncodingStrategyIsNotSupported(format: ConfigSerializationFormat)
}

public extension RootConfig {

    func write(to path: URL, as format: ConfigSerializationFormat = .json, using keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
        // var data: Data

        switch format {
            case .json:
                let encoder = JSONEncoder()
                encoder.userInfo = userInfo
                encoder.keyEncodingStrategy = keyEncodingStrategy ?? .useDefaultKeys
                try encoder.encode(self).write(to: path)
            case .yaml:
                Emitter.Options.doubleFormatStyle = .decimal
                if let _ = keyEncodingStrategy {
                    throw ConfigSerializationError.keyEncodingStrategyIsNotSupported(format: format)
                }
                let encoder = YAMLEncoder()

                print(try Yams.dump(object: [1.0, 2.0]))
                print("encoding")
                print(try encoder.encode([1.0, 2.0]))
                print(try encoder.encode(self, userInfo: userInfo))

                try encoder.encode(self, userInfo: userInfo).write(to: path, atomically: false, encoding: .utf8)
            // default:
            //     throw ConfigSerializationError.formatIsNotSupported(format: format)
        }

        // try data.write(to: path)
    }

    var header: String { asHeader() }

    func asHeader(separator: String = "\t") -> String {
        self.name.components(separatedBy: Expander.nameKeySeparator).map { key in
            key.components(separatedBy: Expander.nameKeyValueSeparator).first!
        }.joined(separator: separator)
    }

    var row: String { asRow() }

    func asRow(separator: String = "\t") -> String {
        self.name.components(separatedBy: Expander.nameKeySeparator).map { key in
            let keyComponents = key.components(separatedBy: Expander.nameKeyValueSeparator)
            if keyComponents.count < 2 {
                return ""
            }
            return keyComponents.last!
        }.joined(separator: separator)
    }
}
