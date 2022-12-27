import XCTest

@testable import Swat

final class ConfigExpansionTests: XCTestCase {
    func testFlatConfigExpansion() throws {
        let configs = expand(
            try! read(
                """
                foo:
                    - bar
                    - baz
                """
            )
        )

        XCTAssertEqual(
            configs.count, 2, "Number of configs is not equal to the expected value"
        )
    }

    func testListWhichMustNotBeExpanded() throws {
        let configs = try! expand(
            read(
                """
                foo: # as-is
                    - bar
                    - baz
                """
            )
        )

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }
}
