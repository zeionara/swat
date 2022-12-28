import XCTest

@testable import Swat

class ConfigExpansionTests: XCTestCase {
    var reader: ConfigSpecReader? = nil
    var expander: Expander? = nil

    enum InitializationError: Error {
        case readerOrExpanderIsEmpty
    }

    override func setUp() {
        self.reader = ConfigSpecReader()
        self.expander = Expander()
    }
}
