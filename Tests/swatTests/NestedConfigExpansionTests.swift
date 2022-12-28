import XCTest

@testable import Swat

final class NestedConfigExpansionTests: ConfigExpansionTests {

    func testTrivialCase() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    bar:
                        - baz
                        - qux
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 2, "Number of configs is not equal to the expected value"
        )
    }

    func testNestedFieldWhichMustNotBeExpanded() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    bar: # as-is
                        baz:
                            - qux
                            - quux
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }

    func testNestedListWhichMustNotBeExpanded() throws {
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    bar: # as-is
                        - baz
                        - qux
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }

    func testListOfObjectsWhichMustNotBeExpanded() throws {  // TODO: implement this test in cuco package
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    bar: # as-is
                        - baz:
                            qux:
                                - quux
                                - quuz
                        - corge:
                            grault:
                                - garply
                                - waldo
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 1, "Number of configs is not equal to the expected value"
        )
    }

    func testListOfObjectsWhichMustBeExpanded() throws {  // TODO: implement thi test in cuco package
        guard let reader = reader, let expander = expander else { throw InitializationError.readerOrExpanderIsEmpty }

        let configs = 
            try! reader.read(
                """
                foo:
                    bar:
                        - baz:
                            qux:
                                - quux
                                - quuz
                        - corge:
                            grault:
                                - garply
                                - waldo
                """
            )
            |> expander.expand

        XCTAssertEqual(
            configs.count, 4, "Number of configs is not equal to the expected value"
        )
    }

}
