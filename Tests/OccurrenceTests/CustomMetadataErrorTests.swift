import XCTest
import Logging
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Occurrence

final class CustomMetadataErrorTests: XCTestCase {
    
    func testMetadataErrorConformance() throws {
        struct AnyMetadataError: CustomMetadataError {
            static let errorDomain: String = "any-error-domain"
            let errorCode: Int = 404
            let description: String = "My unique error case"
        }
        
        let metadata = AnyMetadataError().metadata
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.stringValue)
        let description = try XCTUnwrap(metadata[.description]?.stringValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        
        XCTAssertEqual(domain, "any-error-domain")
        XCTAssertEqual(code, "404")
        XCTAssertEqual(description, "My unique error case")
        #if os(Linux)
        XCTAssertEqual(localizedDescription, "The operation could not be completed. (any-error-domain error 404.)")
        #else
        XCTAssertEqual(localizedDescription, "The operation couldn’t be completed. (any-error-domain error 404.)")
        #endif
    }
    
    func testLocalizedErrorConformance() throws {
        struct AnyMetadataError: CustomMetadataError, LocalizedError {
            static let errorDomain: String = "some-error-domain"
            let errorCode: Int = 500
            let description: String = "An error case"
            let errorDescription: String? = "This takes precedence"
            let failureReason: String? = "The thing could not be done"
            let recoverySuggestion: String? = "Try a different thing"
        }
        
        let metadata = AnyMetadataError().metadata
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.stringValue)
        let description = try XCTUnwrap(metadata[.description]?.stringValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        let localizedFailureReason = try XCTUnwrap(metadata[.localizedFailureReason]?.stringValue)
        let localizedRecoverySuggestion = try XCTUnwrap(metadata[.localizedRecoverySuggestion]?.stringValue)
        
        XCTAssertEqual(domain, "some-error-domain")
        XCTAssertEqual(code, "500")
        XCTAssertEqual(description, "An error case")
        XCTAssertEqual(localizedDescription, "This takes precedence")
        XCTAssertEqual(localizedFailureReason, "The thing could not be done")
        XCTAssertEqual(localizedRecoverySuggestion, "Try a different thing")
    }
    
    func testCocoaErrorConformance() throws {
        let metadata = CocoaError(.featureUnsupported).metadata
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.stringValue)
        let description = try XCTUnwrap(metadata[.description]?.stringValue)
        
        XCTAssertEqual(domain, "NSCocoaErrorDomain")
        XCTAssertEqual(code, "3328")
        #if os(Linux)
        XCTAssertEqual(description, #"Error Domain=NSCocoaErrorDomain Code=3328 "The requested operation is not supported.""#)
        #else
        XCTAssertEqual(description, "The requested operation couldn’t be completed because the feature is not supported.")
        #endif
    }
    
    func testURLErrorConformance() throws {
        let metadata = URLError(.cancelled).metadata
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.stringValue)
        let description = try XCTUnwrap(metadata[.description]?.stringValue)
        
        XCTAssertEqual(domain, "NSURLErrorDomain")
        XCTAssertEqual(code, "-999")
        #if os(Linux)
        XCTAssertEqual(description, #"Error Domain=NSURLErrorDomain Code=-999 "(null)""#)
        #else
        XCTAssertEqual(description, "The operation couldn’t be completed. (NSURLErrorDomain error -999.)")
        #endif
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
        
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.stringValue)
        let description = try XCTUnwrap(metadata[.description]?.stringValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        
        XCTAssertEqual(domain, "SwiftEncodingErrorDomain")
        XCTAssertEqual(code, "0")
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
        
        let domain = try XCTUnwrap(metadata[.domain]?.stringValue)
        let code = try XCTUnwrap(metadata[.code]?.stringValue)
        let description = try XCTUnwrap(metadata[.description]?.stringValue)
        let localizedDescription = try XCTUnwrap(metadata[.localizedDescription]?.stringValue)
        
        XCTAssertEqual(domain, "SwiftDecodingErrorDomain")
        XCTAssertEqual(code, "0")
        XCTAssertEqual(description, #"Decoding (Type Mismatch) - Type: Int, Context: Unexpected type. ["code"]"#)
        #if os(Linux)
        XCTAssertEqual(localizedDescription, "The operation could not be completed. The data isn’t in the correct format.")
        #else
        XCTAssertEqual(localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
        #endif
    }
}
