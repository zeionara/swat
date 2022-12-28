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

    func testTrivialCase() throws {
        guard let factory = factory else { throw InitializationError.factoryIsEmpty }

        // print(Path.assets.appendingPathComponentIfNotNull(URL(string: "ObjectCreation/Foo")))

        factory.make(in: URL(string: "Foo"))

        // XCTAssertEqual(
        //     configs.count, 2, "Number of configs is not equal to the expected value"
        // )
    }

}
