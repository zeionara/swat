import XCTest

@testable import Swat

final class FileLoadingTests: XCTestCase {
    func testFileLoading() throws {
        let content = try! ConfigSpecReader(at: Path.testAssets).read(from: "singleFile.yml")

        XCTAssert(
            NSDictionary(
                dictionary: content.dict
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testFileReferenceHandling() throws {
        let content = try! ConfigSpecReader(at: Path.testAssets.appendingPathComponent("MultipleFiles")).read(from: "foo.yml")

        XCTAssert(
            NSDictionary(
                dictionary: content.dict
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testFileFromOtherFolderLink() throws {
        let content = try! ConfigSpecReader(at: Path.testAssets).read(
            """
            foo: 
                bar: MultipleFiles/baz.yml
            """
        )

        XCTAssert(
            NSDictionary(
                dictionary: content.dict
            ).isEqual(
                to: ["foo": ["bar": ["baz": ["qux", "quux"]]]]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testSingleFolderLink() throws {
        let content = try! ConfigSpecReader(at: Path.testAssets.appendingPathComponent("SingleFolder")).read(from: "foo.yml")

        XCTAssert(
            NSDictionary(
                dictionary: content.dict
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

    func testFolderTreeLink() throws {
        let content = try! ConfigSpecReader(at: Path.testAssets.appendingPathComponent("NestedFolder")).read(from: "foo.yml")

        XCTAssert(
            NSDictionary(
                dictionary: content.dict
            ).isEqual(
                to: [
                    "foo": [
                        "bar": [[
                            ["qux": "quux"]
                        ]]
                    ]
                ]
            ), "Expected and loaded dictionaries are not the same"
        )
    }

    func testLinkListExpansion() throws {
        let content =
            try! ConfigSpecReader(at: Path.testAssets.appendingPathComponent("LinkList")).read(from: "foo.yml")
            |> expand

        XCTAssertEqual(
            content.count, 4, "Number of expected values is different from what is expected"
        )
    }
}
