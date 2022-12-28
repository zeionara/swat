import XCTest

@testable import Swat

final class ConfigExpansionTests: XCTestCase {
    func testFlatConfigExpansion() throws {
        let configs = 
            try! ConfigSpecReader().read(
                """
                foo:
                    - bar
                    - baz
                """
            )
            |> expand

        XCTAssertEqual(
            configs.count, 2, "Number of configs is not equal to the expected value"
        )
    }

    func testListWhichMustNotBeExpanded() throws {
        let configs = 
            try! ConfigSpecReader().read(
                """
                foo: # as-is
                    - bar
                    - baz
                """
            )
            |> expand

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }
}
