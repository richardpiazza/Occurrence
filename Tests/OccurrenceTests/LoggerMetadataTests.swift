import Foundation
import Logging
@testable import Occurrence
import Testing

struct LoggerMetadataTests {

    /// Verify that an `NSError` can be reconstructed from `Logger.Metadata`
    /// when certain conditions are met.
    @Test func nsErrorRepresentation() throws {
        var metadata: Logger.Metadata = [:]

        #expect(metadata.nsError == nil)
        metadata[.domain] = .string("SomeErrorDomain")
        #expect(metadata.nsError == nil)
        metadata[.code] = .stringConvertible(123)

        var nsError = try #require(metadata.nsError)

        #expect(nsError.domain == "SomeErrorDomain")
        #expect(nsError.code == 123)
        #expect(nsError.userInfo.isEmpty)

        metadata[.userInfo] = .dictionary([
            "context": .string("Unit Tests"),
            "pass": .stringConvertible(true),
        ])

        nsError = try #require(metadata.nsError)

        #expect(nsError.userInfo.count == 2)
        let context = try #require(nsError.userInfo["context"] as? String)
        #expect(context == "Unit Tests")
        let pass = try #require(nsError.userInfo["pass"] as? Bool)
        #expect(pass)
    }
}
