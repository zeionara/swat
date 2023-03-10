import XCTest

@testable import Swat

final class FlatConfigExpansionTests: ConfigExpansionTests {

    func testTrivialCase() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    - bar
                    - baz
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 2, "Number of configs is not equal to the expected value"
        )
    }

    func testListWhichMustNotBeExpanded() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo: # as-is
                    - bar
                    - baz
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }

    func testListWhichMustNotBeExpandedAndListWhichMustBeExpanded() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    - bar
                    - baz
                qux: # as-is
                    - quux
                    - quuz
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 2, "Number of configs is not equal to the expected value"
        )
    }

    func testListWhichMustNotBeExpandedWithTrailingCharactersInComment() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo: # as-is (must not be expanded)
                    - bar
                    - baz
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }
}
