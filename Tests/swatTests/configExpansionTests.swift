import XCTest

@testable import Swat

final class ConfigExpansionTests: XCTestCase {
    var reader: ConfigSpecReader? = nil
    var expander: Expander? = nil

    enum InitializationError: Error {
        case readerOrExpanderIsEmpty
    }

    override func setUp() {
        self.reader = ConfigSpecReader()
        self.expander = Expander()
    }

    func testFlatConfigExpansion() throws {
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
}
