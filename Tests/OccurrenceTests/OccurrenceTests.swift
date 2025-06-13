import Logging
@testable import Occurrence
import XCTest

class OccurrenceTests: XCTestCase {

    @LazyLogger(.occurrence) var log: Logger

    let metadataProvider = Logger.MetadataProvider {
        ["context": "XCTestCase"]
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        Occurrence.bootstrap(metadataProvider: metadataProvider)
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

    func testConvenienceDictionary() throws {
        let dictionary: [String: Any] = [
            "label": "count",
            "value": 42,
        ]

        log.log(level: .info, "Dictionary", dictionary: dictionary, redacting: ["value"])

        let entry = try XCTUnwrap(Occurrence.logProvider.entries().first)
        var description = entry.description

        // Remove the timestamp
        let first = description.index(description.startIndex, offsetBy: 1)
        let last = description.index(description.startIndex, offsetBy: 25)
        description.replaceSubrange(first ... last, with: "")

        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceDictionary() 39] Dictionary { context: XCTestCase, label: count, value: <REDACTED> }
        """

        XCTAssertEqual(description, output)
    }

    func testConvenienceEncodable() throws {
        struct Metadata: Encodable {
            let id: Int
            let name: String
        }

        log.log(level: .info, "Encodable", encodable: Metadata(id: 123, name: "Bob"), redacting: ["name"])

        let entry = try XCTUnwrap(Occurrence.logProvider.entries().first)
        var description = entry.description

        // Remove the timestamp
        let first = description.index(description.startIndex, offsetBy: 1)
        let last = description.index(description.startIndex, offsetBy: 25)
        description.replaceSubrange(first ... last, with: "")

        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceEncodable() 62] Encodable { context: XCTestCase, id: 123, name: <REDACTED> }
        """

        XCTAssertEqual(description, output)
    }
}
