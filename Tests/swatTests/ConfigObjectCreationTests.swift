import XCTest
import Runtime

@testable import Swat

final class ConfigObjectCreationTests: XCTestCase {
    var factory: ConfigFactory? = nil

    enum InitializationError: Error {
        case factoryIsEmpty
    }

    override func setUp() {
        self.factory = ConfigFactory(at: Path.testAssets.appendingPathComponent("ConfigObjectCreation"))
    }

    func runTest<T>(from fileName: String = ConfigFactory.defaultFileName, in directory: String, count targetCount: Int) throws -> [T] where T: Config {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        let configs: [T] = try factory.make(from: fileName, in: URL(string: directory))

        XCTAssertEqual(
            configs.count, targetCount, "Number of configs is not equal to the expected value"
        )

        return configs
    }

    func testTrivialCase() throws {
        let _: [TrivialConfig] = try runTest(in: "TrivialConfig", count: 2)
    }

    func testCustomizedKeys() throws {
        let _: [TrivialConfigWithCustomizedKeys] = try runTest(in: "TrivialConfig", count: 2)
    }

    func testMultiwordCase() throws {
        let _: [MultiwordConfig] = try runTest(in: "MultiwordConfig", count: 2)
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
        let _: [ConfigWithArrayTypedProperty] = try runTest(in: "ConfigWithArrayTypedProperty", count: 2)
    }

    func testForceArrayTypedPropertyExpansion() throws {
        let _: [ConfigWithArrayTypedProperty] = try runTest(from: "forcedArrayExpansion.yml", in: "ConfigWithArrayTypedProperty", count: 4)
    }

    func testNestedObjectsDecoding() throws {
        let configs: [ConfigWithNestedObject] = try runTest(in: "ConfigWithNestedObject", count: 2)
        print(configs)
    }

}
