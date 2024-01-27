import XCTest
import Logging
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Occurrence

final class LoggableErrorTests: XCTestCase {
    
    func testLoggableErrorConformance() throws {
        struct AnyMetadataError: CustomNSError, LoggableError {
            static let errorDomain: String = "any-error-domain"
            let errorCode: Int = 404
            var errorUserInfo: [String : Any] = [
                "answer": 42
            ]
        }
        
        let metadata = AnyMetadataError().metadata
        XCTAssertEqual(metadata.count, 3)
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.intValue)
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        let answer = try XCTUnwrap(userInfo["answer"]?.intValue)
        
        XCTAssertEqual(domain, "any-error-domain")
        XCTAssertEqual(code, 404)
        XCTAssertEqual(answer, 42)
    }
    
    func testLocalizedErrorConformance() throws {
        struct AnyMetadataError: CustomNSError, LocalizedError, LoggableError {
            static let errorDomain: String = "some-error-domain"
            let errorCode: Int = 500
            let errorDescription: String? = "This takes precedence"
            let failureReason: String? = "The thing could not be done"
            let recoverySuggestion: String? = "Try a different thing"
        }
        
        let error = AnyMetadataError()
        let metadata = error.metadata
        XCTAssertEqual(metadata.count, 6)
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.intValue)
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        let localizedFailureReason = try XCTUnwrap(metadata[.localizedFailureReason]?.stringValue)
        let localizedRecoverySuggestion = try XCTUnwrap(metadata[.localizedRecoverySuggestion]?.stringValue)
        
        XCTAssertEqual(domain, "some-error-domain")
        XCTAssertEqual(code, 500)
        XCTAssertEqual(userInfo.count, 0)
        XCTAssertEqual(localizedDescription, "This takes precedence")
        XCTAssertEqual(localizedFailureReason, "The thing could not be done")
        XCTAssertEqual(localizedRecoverySuggestion, "Try a different thing")
    }
    
    func testCocoaErrorConformance() throws {
        let metadata = CocoaError(.featureUnsupported).metadata
        XCTAssertEqual(metadata.count, 3)
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.intValue)
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        
        XCTAssertEqual(domain, "NSCocoaErrorDomain")
        XCTAssertEqual(code, 3328)
        XCTAssertEqual(userInfo.count, 0)
    }
    
    func testURLErrorConformance() throws {
        let metadata = URLError(.cancelled).metadata
        XCTAssertEqual(metadata.count, 3)
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.intValue)
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        
        XCTAssertEqual(domain, "NSURLErrorDomain")
        XCTAssertEqual(code, -999)
        XCTAssertEqual(userInfo.count, 0)
    }
    
    func testEncodingErrorConformance() throws {
        struct FileRef: Encodable {
            let description: String = "Some File"
        }
        
        let context = EncodingError.Context(
            codingPath: [Logger.MetadataKey.description, Logger.MetadataKey.file],
            debugDescription: "Bad data."
        )
        let error = EncodingError.invalidValue(FileRef(), context)
        let metadata = error.metadata
        XCTAssertEqual(metadata.count, 4)
        
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.intValue)
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        let description = try XCTUnwrap(userInfo[.description]?.stringValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        
        XCTAssertEqual(domain, "SwiftEncodingErrorDomain")
        XCTAssertEqual(code, 0)
        XCTAssertEqual(userInfo.count, 1)
        XCTAssertEqual(description, #"Encoding (Invalid Value) - Value: FileRef(description: "Some File"), Context: Bad data. ["description", "file"]"#)
        #if os(Linux)
        XCTAssertEqual(localizedDescription, "The operation could not be completed. The data isn’t in the correct format.")
        #else
        XCTAssertEqual(localizedDescription, "The data couldn’t be written because it isn’t in the correct format.")
        #endif
    }
    
    func testDecodingErrorConformance() throws {
        let context = DecodingError.Context(
            codingPath: [Logger.MetadataKey.code],
            debugDescription: "Unexpected type."
        )
        let error = DecodingError.typeMismatch(Int.self, context)
        let metadata = error.metadata
        XCTAssertEqual(metadata.count, 4)
        
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.intValue)
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        let description = try XCTUnwrap(userInfo[.description]?.stringValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        
        XCTAssertEqual(domain, "SwiftDecodingErrorDomain")
        XCTAssertEqual(code, 0)
        XCTAssertEqual(userInfo.count, 1)
        XCTAssertEqual(description, #"Decoding (Type Mismatch) - Type: Int, Context: Unexpected type. ["code"]"#)
        #if os(Linux)
        XCTAssertEqual(localizedDescription, "The operation could not be completed. The data isn’t in the correct format.")
        #else
        XCTAssertEqual(localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
        #endif
    }
    
    func testMetadataRedactions() throws {
        struct RedactionError: CustomNSError, LoggableError {
            static var errorDomain: String { "redaction-error" }
            var errorCode: Int { 0 }
            var errorUserInfo: [String : Any] {
                [
                    "first": "Something",
                    "second": [
                        "third": "Secret"
                    ],
                    "fourth": 47
                ]
            }
        }
            
        let error = RedactionError()
        let metadata = error.metadata(redactingUserInfo: ["second.third", "fourth"])
        let userInfo = try XCTUnwrap(metadata[.userInfo]?.dictionaryValue)
        
        XCTAssertEqual(userInfo["first"]?.stringValue, "Something")
        XCTAssertEqual(userInfo["second"]?.dictionaryValue?["third"]?.stringValue, "<REDACTED>")
        XCTAssertEqual(userInfo["fourth"]?.stringValue, "<REDACTED>")
    }
}
