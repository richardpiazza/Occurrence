import XCTest
@testable import Occurrence

final class RedactionTests: XCTestCase {
    
    private let dictionary: [String: Any] = [
        "a": "one",
        "b": "two",
        "c": ["d": "three"]
    ]
    
    func testKeyPathRedaction() throws {
        let redactedDictionary = dictionary.redacting(keyPaths: ["a", "c.d"])
        XCTAssertEqual(redactedDictionary.keys.sorted(), ["a", "b", "c"])
        XCTAssertEqual(redactedDictionary["a"] as? String, "<REDACTED>")
        XCTAssertEqual(redactedDictionary["b"] as? String, "two")
        XCTAssertEqual(redactedDictionary["c"] as? [String: String], ["d": "<REDACTED>"])
    }
}
