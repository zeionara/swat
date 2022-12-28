import XCTest

@testable import Swat

struct Foo: Decodable {
    // enum Category: String, Decodable {
    //     case foo, bar
    // }

    // enum CodingKeys: String, CodingKey {
    //     case fox = "foo", baz = "bar"
    // }

    enum CodingKeys: String, CodingKey {
        case fooBar, barBaz
    }

    let fooBar: Int
    let barBaz: String
}

final class ConfigObjectCreationTests: XCTestCase {
    var factory: ConfigFactory? = nil

    enum InitializationError: Error {
        case factoryIsEmpty
    }

    override func setUp() {
        self.factory = ConfigFactory(at: Path.testAssets.appendingPathComponent("ConfigObjectCreation"))
    }

    func testTrivialCase() throws {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        // print(Path.assets.appendingPathComponentIfNotNull(URL(string: "ObjectCreation/Foo")))

        let configs: [Foo] = try factory.make(in: URL(string: "Foo"))
        print(configs)

        // print(configs)

        // let res = try! factory.make(in: URL(string: "Foo")).map { config in
        //     let json = try JSONSerialization.data(withJSONObject: config)
        //     // let decoder = JSONDecoder()

        //     let foo = try! JSONDecoder().decode(Foo.self, from: json)
        //     return foo
        // }

        // print(res)

        XCTAssertEqual(
            configs.count, 2, "Number of configs is not equal to the expected value"
        )
    }

}
