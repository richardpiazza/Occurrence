import XCTest
@testable import Occurrence

final class RedactionTests: XCTestCase {
    
    private let dictionary: [String: Any] = [
        "a": "one",
        "b": "two",
        "c": ["d": "three"]
    ]
    
    func testKeyPathRedaction() throws {
        let redacted = JSONSerialization.redact(dictionary, redacting: ["a", "c.d"])
        let redactedDictionary = try XCTUnwrap(redacted as? [String: Any])
        
        XCTAssertEqual(redactedDictionary.keys.sorted(), ["a", "b", "c"])
        XCTAssertEqual(redactedDictionary["a"] as? String, "<REDACTED>")
        XCTAssertEqual(redactedDictionary["b"] as? String, "two")
        XCTAssertEqual(redactedDictionary["c"] as? [String: String], ["d": "<REDACTED>"])
    }
    
    func testJSONRepresentation() throws {
        let json = try JSONSerialization.json(withJSONObject: dictionary, redacting: ["a", "c.d"])
        XCTAssertEqual(json, """
        {
          "a" : "<REDACTED>",
          "b" : "two",
          "c" : {
            "d" : "<REDACTED>"
          }
        }
        """)
    }
}
