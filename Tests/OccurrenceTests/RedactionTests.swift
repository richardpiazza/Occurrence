import Foundation
@testable import Occurrence
import Testing

struct RedactionTests {

    private let dictionary: [String: Any] = [
        "a": "one",
        "b": "two",
        "c": ["d": "three"],
    ]

    @Test func redactingKeyPaths() throws {
        let redactedDictionary = dictionary.redacting(keyPaths: ["a", "c.d"])
        #expect(redactedDictionary.keys.sorted() == ["a", "b", "c"])
        #expect(redactedDictionary["a"] as? String == "<REDACTED>")
        #expect(redactedDictionary["b"] as? String == "two")
        #expect(redactedDictionary["c"] as? [String: String] == ["d": "<REDACTED>"])
    }

    @Test func redactingUserInfo() throws {
        struct RedactionError: CustomNSError, LoggableError {
            static var errorDomain: String { "redaction-error" }
            var errorCode: Int { 0 }
            var errorUserInfo: [String: Any] {
                [
                    "first": "Something",
                    "second": [
                        "third": "Secret",
                    ],
                    "fourth": 47,
                ]
            }
        }

        let error = RedactionError()
        let metadata = error.metadata(redactingUserInfo: ["second.third", "fourth"])
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)

        #expect(userInfo["first"]?.stringValue == "Something")
        #expect(userInfo["second"]?.dictionaryValue?["third"]?.stringValue == "<REDACTED>")
        #expect(userInfo["fourth"]?.stringValue == "<REDACTED>")
    }
}
