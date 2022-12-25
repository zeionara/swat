import XCTest

@testable import Swat

final class FileLoadingTests: XCTestCase {
    func testFileLoading() throws {
        XCTAssert(
            NSDictionary(
                dictionary: try! read(from: "singleFile.yml", in: Path.testAssets)
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }
}
