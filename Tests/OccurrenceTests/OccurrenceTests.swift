import XCTest
import Logging
@testable import Occurrence

class OccurrenceTests: XCTestCase {
    
    @LazyLogger(.occurrence) var log: Logger
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Occurrence.bootstrap()
    }
    
    override class func tearDown() {
        Occurrence.logProvider.purge()
        super.tearDown()
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
        
        enum Key: CodingKey {
            case name
        }
        
        let context = DecodingError.Context(codingPath: [Key.name], debugDescription: "'Name' not found", underlyingError: nil)
        let error = DecodingError.keyNotFound(Key.name, context)
        
        log.error("A Basic Error", metadata: .init(error: BasicError()))
        log.error("A Detailed Error", metadata: .init(localizedError: ExtendedError()))
        log.error("A Decoding Error", metadata: .init(decodingError: error))
    }

    static var allTests = [
        ("testMessage", testMessage),
        ("testMetadata", testMetadata),
    ]
}
