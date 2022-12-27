import XCTest

@testable import Swat

final class FileLoadingTests: XCTestCase {
    func testFileLoading() throws {
        let content = try! read(from: "singleFile.yml", in: Path.testAssets)

        XCTAssert(
            NSDictionary(
                dictionary: content
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testFileReferenceHandling() throws {
        let content = try! read(from: "foo.yml", in: Path.testAssets.appendingPathComponent("MultipleFiles"))

        XCTAssert(
            NSDictionary(
                dictionary: content
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testFileFromOtherFolderLink() throws {
        let content = try! read(
            """
            foo: 
                bar: MultipleFiles/baz.yml
            """,
            in: Path.testAssets
        )

        XCTAssert(
            NSDictionary(
                dictionary: content
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testSingleFolderLink() throws {
        let content = try! read(from: "foo.yml", in: Path.testAssets.appendingPathComponent("SingleFolder"))

        XCTAssert(
            NSDictionary(
                dictionary: content
            ).isEqual(
                to: [
                    "foo": [
                        "bar": [
                            ["baz": ["qux", "quux"]]
                        ]
                    ]
                ]
            ), "Expected and loaded dictionaries are not the same"
        )
    }
}
