import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging
@testable import Occurrence
import Testing

struct LoggableErrorTests {

    @Test func customNSError() throws {
        struct AnyMetadataError: CustomNSError, LoggableError {
            static let errorDomain: String = "any-error-domain"
            let errorCode: Int = 404
            var errorUserInfo: [String: Any] = [
                "answer": 42,
            ]
        }

        let metadata = AnyMetadataError().metadata
        #expect(metadata.count == 3)

        let domain = try #require(metadata[.domain]?.stringValue)
        let code = try #require(metadata[.code]?.intValue)
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)
        let answer = try #require(userInfo["answer"]?.intValue)

        #expect(domain == "any-error-domain")
        #expect(code == 404)
        #expect(answer == 42)
    }

    @Test func customLocalizedError() throws {
        struct AnyMetadataError: CustomNSError, LocalizedError, LoggableError {
            static let errorDomain: String = "some-error-domain"
            let errorCode: Int = 500
            let errorDescription: String? = "This takes precedence"
            let failureReason: String? = "The thing could not be done"
            let recoverySuggestion: String? = "Try a different thing"
        }

        let error = AnyMetadataError()
        let metadata = error.metadata
        #expect(metadata.count == 6)

        let domain = try #require(metadata[.domain]?.stringValue)
        let code = try #require(metadata[.code]?.intValue)
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)
        let localizedDescription = try #require(metadata[.localizedDescription]?.stringValue)
        let localizedFailureReason = try #require(metadata[.localizedFailureReason]?.stringValue)
        let localizedRecoverySuggestion = try #require(metadata[.localizedRecoverySuggestion]?.stringValue)

        #expect(domain == "some-error-domain")
        #expect(code == 500)
        #expect(userInfo.count == 0)
        #expect(localizedDescription == "This takes precedence")
        #expect(localizedFailureReason == "The thing could not be done")
        #expect(localizedRecoverySuggestion == "Try a different thing")
    }

    @Test func cocoaError() throws {
        let metadata = CocoaError(.featureUnsupported).metadata
        #expect(metadata.count == 3)

        let domain = try #require(metadata[.domain]?.stringValue)
        let code = try #require(metadata[.code]?.intValue)
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)

        #expect(domain == "NSCocoaErrorDomain")
        #expect(code == 3328)
        #expect(userInfo.count == 0)
    }

    @Test func urlError() throws {
        let metadata = URLError(.cancelled).metadata
        #expect(metadata.count == 3)

        let domain = try #require(metadata[.domain]?.stringValue)
        let code = try #require(metadata[.code]?.intValue)
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)

        #expect(domain == "NSURLErrorDomain")
        #expect(code == -999)
        #expect(userInfo.count == 0)
    }

    @Test func encodingError() throws {
        struct FileRef: Encodable {
            let description: String = "Some File"
        }

        let context = EncodingError.Context(
            codingPath: [Logger.MetadataKey.description, Logger.MetadataKey.file],
            debugDescription: "Bad data.",
        )
        let error = EncodingError.invalidValue(FileRef(), context)
        let metadata = error.metadata
        #expect(metadata.count == 4)

        let domain = try #require(metadata[.domain]?.stringValue)
        let code = try #require(metadata[.code]?.intValue)
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)
        let description = try #require(userInfo[.description]?.stringValue)
        let localizedDescription = try #require(metadata[.localizedDescription]?.stringValue)

        #expect(domain == "SwiftEncodingErrorDomain")
        #expect(code == 0)
        #expect(userInfo.count == 1)
        #expect(description == #"Encoding (Invalid Value) - Value: FileRef(description: "Some File"), Context: Bad data. ["description", "file"]"#)
        #if os(Linux)
        #expect(localizedDescription == "The operation could not be completed. (SwiftEncodingErrorDomain error 0.)")
        #else
        #expect(localizedDescription == "The data couldn’t be written because it isn’t in the correct format.")
        #endif
    }

    @Test func decodingError() throws {
        let context = DecodingError.Context(
            codingPath: [Logger.MetadataKey.code],
            debugDescription: "Unexpected type.",
        )
        let error = DecodingError.typeMismatch(Int.self, context)
        let metadata = error.metadata
        #expect(metadata.count == 4)

        let domain = try #require(metadata[.domain]?.stringValue)
        let code = try #require(metadata[.code]?.intValue)
        let userInfo = try #require(metadata[.userInfo]?.dictionaryValue)
        let description = try #require(userInfo[.description]?.stringValue)
        let localizedDescription = try #require(metadata[.localizedDescription]?.stringValue)

        #expect(domain == "SwiftDecodingErrorDomain")
        #expect(code == 0)
        #expect(userInfo.count == 1)
        #expect(description == #"Decoding (Type Mismatch) - Type: Int, Context: Unexpected type. ["code"]"#)
        #if os(Linux)
        #expect(localizedDescription == "The operation could not be completed. (SwiftDecodingErrorDomain error 0.)")
        #else
        #expect(localizedDescription == "The data couldn’t be read because it isn’t in the correct format.")
        #endif
    }
}
