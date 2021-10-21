import XCTest
import Logging
@testable import Occurrence

class OccurrenceTests: XCTestCase {
    
    @LazyLogger(.occurrence) var log: Logger
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Occurrence.bootstrap()
    }
    
    func testMessage() {
        log.trace("A 'TRACE' Message")
        log.debug("A 'DEBUG' Message")
        log.info("A 'INFO' Message")
        log.notice("A 'NOTICE' Message")
        log.warning("A 'WARNING' Message")
        log.error("A 'ERROR' Message")
        log.critical("A 'CRITICAL' Message")
    }
    
    func testMetadata() {
        struct BasicError: Error {
        }
        
        struct ExtendedError: LocalizedError {
            var errorDescription: String? { "Description of the error." }
            var failureReason: String? { "The reason for the failure." }
            var recoverySuggestion: String? { "How to recover from the error." }
            var helpAnchor: String? { "Help information for the user." }
        }
        
        log.error("A Basic Error", error: BasicError())
        log.error("A Detailed Error", error: ExtendedError())
    }

    static var allTests = [
        ("testMessage", testMessage),
        ("testMetadata", testMetadata),
    ]
}
