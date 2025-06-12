import Foundation
import Logging

/// An `Error` type which can produced `Logger.Metadata` suitable for logging.
///
/// Although `LoggableError` can be used on its own, the typical implementation would be
/// to combine it with one (or more) of the other error protocols: `CustomNSError`,
/// `LocalizedError`, and `RecoverableError`. For example:
///
/// ```swift
/// enum MyAppError: LocalizedError, LoggableError {
///   case loginFailure
///   case inputValidation
///
///   public var errorUserInfo: [String: Any] {
///     // provided additional details
///     return [:]
///   }
/// }
/// ```
///
/// For more examples, reference `EncodingError` and `DecodingError` in this package.
///
/// Heavily inspired and adapted around the NSError Bridging concepts of
/// [SE-0112](https://github.com/apple/swift-evolution/blob/main/proposals/0112-nserror-bridging.md).
public protocol LoggableError: Error {
    var metadata: Logger.Metadata { get }
}

public extension LoggableError {
    var metadata: Logger.Metadata {
        metadata()
    }

    /// Recurses through the `metadata[.userInfo]` and redacts values as specified by `keyPaths`.
    ///
    /// - parameters:
    ///   - redacting: The _dotted_ paths to be redacted.
    ///   - replacement: Value uses to replace any matched redactions.
    /// - returns: `Logger.Metadata` with the expressed key paths redacted.
    func metadata(redactingUserInfo keyPaths: [String] = [], replacement: String = "<REDACTED>") -> Logger.Metadata {
        var meta: Logger.Metadata = [:]

        if let customNSError = self as? CustomNSError {
            meta[.domain] = .string(type(of: customNSError).errorDomain)
            meta[.code] = .stringConvertible(customNSError.errorCode)
            meta[.userInfo] = .dictionary(customNSError.errorUserInfo.redacting(keyPaths: keyPaths, replacement: replacement).metadata)
        } else {
            let nsError = self as NSError
            meta[.domain] = .string(nsError.domain)
            meta[.code] = .stringConvertible(nsError.code)
            meta[.userInfo] = .dictionary(nsError.userInfo.redacting(keyPaths: keyPaths, replacement: replacement).metadata)
        }

        if let localizedError = self as? LocalizedError {
            if let errorDescription = localizedError.errorDescription {
                meta[.localizedDescription] = .string(errorDescription)
            } else {
                meta[.localizedDescription] = .string(localizedError.localizedDescription)
            }

            if let failureReason = localizedError.failureReason {
                meta[.localizedFailureReason] = .string(failureReason)
            }
            if let recoverySuggestion = localizedError.recoverySuggestion {
                meta[.localizedRecoverySuggestion] = .string(recoverySuggestion)
            }
            if let helpAnchor = localizedError.helpAnchor {
                meta[.localizedHelpAnchor] = .string(helpAnchor)
            }
        }

        if let recoverableError = self as? RecoverableError {
            let options = recoverableError.recoveryOptions.map { Logger.MetadataValue.string($0) }
            meta[.localizedRecoveryOptions] = .array(options)
        }

        return meta
    }
}
