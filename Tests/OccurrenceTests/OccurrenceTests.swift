import XCTest
import Logging
@testable import Occurrence

final class OccurrenceTests: XCTestCase {
    
    @Subsystem(.occurrence, factory: Occurrence.init) private var log: Logger
    
    let logger = Logger(label: "com.richardpiazza.occurrence.tests", factory: Occurrence.init)
    
//    override func setUpWithError() throws {
//        try super.setUpWithError()
//        LoggingSystem.bootstrap(Occurrence.init)
//    }
    
    func testExample() {
        logger.trace("A 'TRACE' Message")
        logger.debug("A 'DEBUG' Message")
        logger.info("A 'INFO' Message")
        logger.notice("A 'NOTICE' Message")
        logger.warning("A 'WARNING' Message")
        logger.error("A 'ERROR' Message")
        logger.critical("A 'CRITICAL' Message")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
