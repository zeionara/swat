import Runtime

enum KeyDecodingError: Error {
    case missingCase(forRawValue: String)
}

public protocol ConfigWithCustomizedKeys: Config {
    associatedtype CodingKeys: CaseIterable
}

public extension ConfigWithCustomizedKeys {
    static func listCaseLabels(of enumerable: Any.Type) throws -> [String] {
        return try typeInfo(of: enumerable).cases.map{ $0.name }
    }

    static func getCaseLabel<T: CaseIterable>(of rawValue: String, in enumerable: T.Type) throws -> String? {
        for (codingKeys, caseLabel) in zip(enumerable.allCases, try listCaseLabels(of: enumerable)) {
            if let codingKeys = codingKeys as? CodingKey, codingKeys.stringValue == rawValue {
                return caseLabel
            }
        }
        return nil
    }

    static func decode(key: String) throws -> String {
        if let key = try getCaseLabel(of: key, in: CodingKeys.self) {
            return key
        }
        throw KeyDecodingError.missingCase(forRawValue: key)
    }
}
