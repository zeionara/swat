import XCTest

@testable import Swat

final class ConfigObjectCreationTests: XCTestCase {
    var factory: ConfigFactory? = nil

    enum InitializationError: Error {
        case factoryIsEmpty
    }

    override func setUp() {
        self.factory = ConfigFactory(at: Path.testAssets.appendingPathComponent("ConfigObjectCreation"))
    }

    func runTest<T>(_ name: String, count targetCount: Int) throws -> [T] where T: Decodable {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        let configs: [T] = try factory.make(in: URL(string: name))

        XCTAssertEqual(
            configs.count, targetCount, "Number of configs is not equal to the expected value"
        )

        return configs
    }

    func testTrivialCase() throws {
        let _: [TrivialConfig] = try runTest("TrivialConfig", count: 2)
        // guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        // let configs: [TrivialConfig] = try factory.make(in: URL(string: "TrivialConfig"))

        // XCTAssertEqual(
        //     configs.count, 2, "Number of configs is not equal to the expected value"
        // )
    }

    func testMultiwordCase() throws {
        let _: [MultiwordConfig] = try runTest("MultiwordConfig", count: 2)
        // guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        // let configs: [MultiwordConfig] = try factory.make(in: URL(string: "MultiwordConfig"))

        // XCTAssertEqual(
        //     configs.count, 2, "Number of configs is not equal to the expected value"
        // )
    }

}
