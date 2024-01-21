import XCTest
import Logging
@testable import Occurrence

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
    
    func testMetadata() {
        struct BasicError: Error {}
        
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
        
        log.error("A Basic Error", metadata: .init(BasicError()))
        log.error("A Detailed Error", metadata: .init(ExtendedError()))
        log.error("A Decoding Error", metadata: .init(error))
    }
    
    func testConvenienceObject() throws {
        class Item: CustomStringConvertible {
            let value: Int
            
            init(value: Int) {
                self.value = value
            }
            
            var description: String {
                "Item { value: \(value) }"
            }
        }
        
        log.log(level: .info, "Object", object: Item(value: 47))
        
        let entry = try XCTUnwrap(Occurrence.logProvider.entries().first)
        var description = entry.description
        
        // Remove the timestamp
        let first = description.index(description.startIndex, offsetBy: 1)
        let last = description.index(description.startIndex, offsetBy: 25)
        description.replaceSubrange(first...last, with: "")
        
        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceObject() 68] Object { context: XCTestCase, object: Item { value: 47 } }
        """
        
        XCTAssertEqual(description, output)
        /**
         XCTAssertEqual failed: ("[🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceObject() 68] Object") is not equal to ("[🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceObject() 68] Object { context: XCTestCase, object: Item { value: 47 } }")
         */
    }
    
    func testConvenienceDictionary() throws {
        let dictionary: [String: Any] = [
            "label": "count",
            "value": 42
        ]
        
        log.log(level: .info, "Dictionary", dictionary: dictionary, redacting: ["value"])
        
        let entry = try XCTUnwrap(Occurrence.logProvider.entries().first)
        var description = entry.description
        
        // Remove the timestamp
        let first = description.index(description.startIndex, offsetBy: 1)
        let last = description.index(description.startIndex, offsetBy: 25)
        description.replaceSubrange(first...last, with: "")
        
        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceDictionary() 91] Dictionary { context: XCTestCase, label: count, value: <REDACTED> }
        """
        
        XCTAssertEqual(description, output)
        /**
         XCTAssertEqual failed: ("[🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceDictionary() 91] Dictionary") is not equal to ("[🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceDictionary() 91] Dictionary { context: XCTestCase, label: count, value: <REDACTED> }")
         */
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
        description.replaceSubrange(first...last, with: "")
        
        let output = """
        [🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceEncodable() 114] Encodable { context: XCTestCase, id: 123, name: <REDACTED> }
        """
        
        XCTAssertEqual(description, output)
        /**
         XCTAssertEqual failed: ("[🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceEncodable() 114] Encodable") is not equal to ("[🔎 INFO     | com.richardpiazza.occurrence | OccurrenceTests.swift | testConvenienceEncodable() 114] Encodable { context: XCTestCase, id: 123, name: <REDACTED> }")
         */
    }
}
