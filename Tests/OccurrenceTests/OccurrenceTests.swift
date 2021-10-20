import XCTest
import Logging
@testable import Occurrence

final class OccurrenceTests: XCTestCase {
    
    @LazyLogger(.occurrence) var log: Logger
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        LoggingSystem.bootstrap(Occurrence.init)
    }
    
    func testExample() {
        log.trace("A 'TRACE' Message")
        log.debug("A 'DEBUG' Message")
        log.info("A 'INFO' Message")
        log.notice("A 'NOTICE' Message")
        log.warning("A 'WARNING' Message")
        log.error("A 'ERROR' Message")
        log.critical("A 'CRITICAL' Message")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
