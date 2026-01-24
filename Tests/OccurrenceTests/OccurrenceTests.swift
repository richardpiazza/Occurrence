import Logging
@testable import Occurrence
import Testing

@Suite(.serialized)
final class OccurrenceTests {

    static let metadataProvider = Logger.MetadataProvider {
        ["context": "XCTestCase"]
    }

    let logger: Logger

    init() {
        Occurrence.bootstrap(metadataProvider: Self.metadataProvider)
        logger = Logger(.occurrence)
    }

    deinit {
        Occurrence.logProvider.purge()
    }

    @Test func levels() {
        logger.trace("A 'TRACE' Message")
        logger.debug("A 'DEBUG' Message")
        logger.info("A 'INFO' Message")
        logger.notice("A 'NOTICE' Message")
        logger.warning("A 'WARNING' Message")
        logger.error("A 'ERROR' Message")
        logger.critical("A 'CRITICAL' Message")
    }

    @Test func dictionaryConvenience() throws {
        let dictionary: [String: Any] = [
            "label": "count",
            "value": 42,
        ]

        logger.log(level: .info, "Dictionary", dictionary: dictionary, redacting: ["value"])

        let entry = try #require(Occurrence.logProvider.entries().last)
        var description = entry.description

        // Remove the timestamp
        let first = description.index(description.startIndex, offsetBy: 1)
        let last = description.index(description.startIndex, offsetBy: 25)
        description.replaceSubrange(first ... last, with: "")

        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests OccurrenceTests.swift | dictionaryConvenience() 39] Dictionary { context: XCTestCase, label: count, value: <REDACTED> }
        """

        #expect(description == output)
    }

    @Test func encodableConvenience() throws {
        struct Metadata: Encodable {
            let id: Int
            let name: String
        }

        logger.log(level: .info, "Encodable", encodable: Metadata(id: 123, name: "Bob"), redacting: ["name"])

        let entry = try #require(Occurrence.logProvider.entries().last)
        var description = entry.description

        // Remove the timestamp
        let first = description.index(description.startIndex, offsetBy: 1)
        let last = description.index(description.startIndex, offsetBy: 25)
        description.replaceSubrange(first ... last, with: "")

        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests OccurrenceTests.swift | encodableConvenience() 62] Encodable { context: XCTestCase, id: 123, name: <REDACTED> }
        """

        #expect(description == output)
    }
}
