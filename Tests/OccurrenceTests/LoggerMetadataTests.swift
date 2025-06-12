import Logging
@testable import Occurrence
import XCTest

final class LoggerMetadataTests: XCTestCase {

    /// Verify that an `NSError` can be reconstructed from `Logger.Metadata`
    /// when certain conditions are met.
    func testNSErrorRepresentation() throws {
        var metadata: Logger.Metadata = [:]

        XCTAssertNil(metadata.nsError)
        metadata[.domain] = .string("SomeErrorDomain")
        XCTAssertNil(metadata.nsError)
        metadata[.code] = .stringConvertible(123)

        var nsError = try XCTUnwrap(metadata.nsError)

        XCTAssertEqual(nsError.domain, "SomeErrorDomain")
        XCTAssertEqual(nsError.code, 123)
        XCTAssertTrue(nsError.userInfo.isEmpty)

        metadata[.userInfo] = .dictionary([
            "context": .string("Unit Tests"),
            "pass": .stringConvertible(true),
        ])

        nsError = try XCTUnwrap(metadata.nsError)

        XCTAssertEqual(nsError.userInfo.count, 2)
        let context = try XCTUnwrap(nsError.userInfo["context"] as? String)
        XCTAssertEqual(context, "Unit Tests")
        let pass = try XCTUnwrap(nsError.userInfo["pass"] as? Bool)
        XCTAssertTrue(pass)
    }
}
