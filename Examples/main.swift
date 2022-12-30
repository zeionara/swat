import Swat
import Foundation

// Config expansion

struct Bar: ConfigWithDefaultKeys {
    let foo: Int
    let bar: String
}

struct Foo: ConfigWithDefaultKeys, RootConfig {
    let foo: Int
    let bar: Bar

    let name: String
}

let configs: [Foo] = try ConfigFactory().make(
    """
    foo: 17
    bar:
        - foo:
            - 17
            - 19
          bar:
            - qux
            - quux
        - foo:
            - 21
            - 23
          bar:
            - corge
            - grault
    name: demo
    """
)

configs.sorted{ $0.bar.foo < $1.bar.foo }.forEach{ print($0) }

// Serialization

// let encoder = JSONEncoder()
// encoder.keyEncodingStrategy = .convertToSnakeCase
// let content = try encoder.encode(configs.first!)
// print(type(of: content))
// 
// print(String(data: content, encoding: String.Encoding.utf8))

// try configs.first!.write(to: Path.assets.appendingPathComponent("config.json"))
try configs.first!.write(to: Path.assets.appendingPathComponent("config.yml"), as: .yaml)
