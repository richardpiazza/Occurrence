import Foundation
import Logging

/// A `Error` that can easily be converted to `Logger.Metadata`.
///
/// A `CustomNSError` defines several useful components:
/// ```swift
/// protocol CustomNSError: Error {
///    static var errorDomain: String { get }
///    var errorCode: Int { get }
///    var errorUserInfo: [String: Any] { get }
/// }
/// ```
public protocol CustomMetadataError: CustomNSError, CustomStringConvertible {
}

public extension CustomMetadataError {
    var metadata: Logger.Metadata {
        var meta: Logger.Metadata = [:]
        meta[.domain] = .string(Self.errorDomain)
        meta[.code] = .string(errorCode.description)
        meta[.localizedDescription] = .string(localizedDescription)
        
        if let localized = self as? LocalizedError {
            if let failureReason = localized.failureReason {
                meta[.localizedFailureReason] = .string(failureReason)
            }
            
            if let recoverySuggestion = localized.recoverySuggestion {
                meta[.localizedRecoverySuggestion] = .string(recoverySuggestion)
            }
        }
        
        return meta
    }
}
