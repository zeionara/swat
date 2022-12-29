import Swat
import Runtime

// enum KeyDecodingError: Error {
//     case missingCase(forRawValue: String)
// }
// 
// func listCaseLabels(of enumerable: Any.Type) throws -> [String] {
//     return try typeInfo(of: enumerable).cases.map{ $0.name }
// }
// 
// func getCaseLabel<T: CaseIterable>(of rawValue: String, in enumerable: T.Type) throws -> String? {
//     for (codingKeys, caseLabel) in zip(enumerable.allCases, try listCaseLabels(of: enumerable)) {
//         if let codingKeys = codingKeys as? CodingKey, codingKeys.stringValue == rawValue {
//             return caseLabel
//         }
//     }
//     return nil
// }

struct TrivialConfigWithCustomizedKeys: ConfigWithCustomizedKeys {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case qux = "foo", quux = "bar", name
    }

    let qux: Int
    let quux: String

    let name: String

    // static func decode(key: String) throws -> String {
    //     if let key = try getCaseLabel(of: key, in: CodingKeys.self) {
    //         return key
    //     }
    //     throw KeyDecodingError.missingCase(forRawValue: key)
    // }
}
