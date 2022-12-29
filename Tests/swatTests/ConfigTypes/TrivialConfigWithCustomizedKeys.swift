import Swat
import Runtime

enum KeyDecodingError: Error {
    case missingCase(forRawValue: String)
}

func listCaseLabels(of enumerable: Any.Type) throws -> [String] {
    return try typeInfo(of: enumerable).cases.map{ $0.name }
}

// func getCaseLabel(of rawValue: String, in enumerable: Any.Type) throws -> [String] {
func getCaseLabel<T: CaseIterable>(of rawValue: String, in enumerable: T.Type) throws -> String? {
    // print(try listCaseLabels(of: enumerable))
    for (codingKeys, caseLabel) in zip(enumerable.allCases, try listCaseLabels(of: enumerable)) {
        if let codingKeys = codingKeys as? CodingKey, codingKeys.stringValue == rawValue {
            return caseLabel
        }
    }
    return nil
}

struct TrivialConfigWithCustomizedKeys: Config {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case qux = "foo", quux = "bar", name

        static func with(label: String) -> CodingKeys? {
            print(self.allCases)
            return self.allCases.first{
                print($0)
                return $0.stringValue == label
            }
        }
    }

    // enum CodingKeyss: String, CaseIterable {
    //     case qux = "foo", quux = "bar", name

    //     static func with(label: String) -> CodingKeyss? {
    //         print(self.allCases)
    //         return self.allCases.first{
    //             print($0)
    //             return "\($0)" == label
    //         }
    //     }
    // }

    let qux: Int
    let quux: String

    let name: String

    static func decode(key: String) throws -> String {
        if let key = try getCaseLabel(of: key, in: CodingKeys.self) {
            return key
        }
        throw KeyDecodingError.missingCase(forRawValue: key)
        // let key = CodingKeys(rawValue: key)
        // print(try! typeInfo(of: CodingKeys.self))
        // print(try! listCaseLabels(of: CodingKeys.self))
        // print(try! getCaseLabel(of: "foo", in: CodingKeys.self))
        // for property in Mirror(reflecting: CodingKeys.qux).children {
        //     print("\(property.label) = \(property.value)")
        // }
        // print(CodingKeyss.with(label: "foo"))
        // return "qux"
    }
}
