import XCTest
import Runtime

@testable import Swat

struct Foo: Config {
    let bar: [String]

    let name: String

    static func decode(key: String) throws -> String {
        return key
    }
}

final class ConfigObjectCreationTests: XCTestCase {
    var factory: ConfigFactory? = nil

    enum InitializationError: Error {
        case factoryIsEmpty
    }

    override func setUp() {
        self.factory = ConfigFactory(at: Path.testAssets.appendingPathComponent("ConfigObjectCreation"))
    }

    func runTest<T>(_ name: String, count targetCount: Int) throws -> [T] where T: Config {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        let configs: [T] = try factory.make(in: URL(string: name))

        XCTAssertEqual(
            configs.count, targetCount, "Number of configs is not equal to the expected value"
        )

        return configs
    }

    func testTrivialCase() throws {
        let _: [TrivialConfig] = try runTest("TrivialConfig", count: 2)
    }

    func testCustomizedKeys() throws {
        let _: [TrivialConfigWithCustomizedKeys] = try runTest("TrivialConfig", count: 2)
    }

    func testMultiwordCase() throws {
        let _: [MultiwordConfig] = try runTest("MultiwordConfig", count: 2)
    }

    func testSingleConfig() throws {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        let config: TrivialConfig = try factory.makeOne(from: "single.yml", in: URL(string: "TrivialConfig"))

        XCTAssertEqual(
            config.foo, 17, "Wrong values of created config object properties"
        )

        XCTAssertEqual(
            config.bar, "baz", "Wrong values of created config object properties"
        )
    }

    func testSingleConfigWithWrongPath() throws {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        func makeConfig() throws {
            let _: TrivialConfig = try factory.makeOne(from: "default.yml", in: URL(string: "TrivialConfig"))
        }

        XCTAssertThrowsError (
            try makeConfig()
        ) { error in
            guard case let .invalidNumberOfElements(count) = (error as! ConfigFactory.ConfigMakingError), count == 2 else {
                XCTFail("Wrong type of error")
                return
            }
        }
    }

    func testCustomConfigName() throws {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        let configs: [TrivialConfig] = try factory.make(from: "custom-name-prefix.yml", in: URL(string: "TrivialConfig")).sorted{ $0.foo < $1.foo }

        XCTAssertEqual(
            configs[0].name, "custom;foo=17", "Incorrect config name"
        )
    }

    func testConfigWithArrayTypedProperty() throws {
        let _: [ConfigWithArrayTypedProperty] = try runTest("ConfigWithArrayTypedProperty", count: 2)
    }

}
