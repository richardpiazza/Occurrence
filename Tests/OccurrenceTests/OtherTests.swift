import XCTest
import Logging
@testable import Occurrence

final class AnotherTests: XCTestCase {
    
    @LazyLogger(.occurrence) var log: Logger
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Occurrence.bootstrap()
    }
    
    func testExample() {
        log.trace("Another 'TRACE' Message")
        log.debug("Another 'DEBUG' Message")
        log.info("Another 'INFO' Message")
        log.notice("Another 'NOTICE' Message")
        log.warning("Another 'WARNING' Message")
        log.error("Another 'ERROR' Message")
        log.critical("Another 'CRITICAL' Message")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
