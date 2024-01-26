import Foundation
import Logging

/// A `Error` that can easily be converted to `Logger.Metadata`.
///
/// This protocol is designed to mirror the `CustomNSError` definition:
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
    var errorUserInfo: [String: Any] { [:] }
    
    var metadata: Logger.Metadata {
        var meta: Logger.Metadata = [:]
        meta[.domain] = .string(Self.errorDomain)
        meta[.code] = .string(errorCode.description)
        meta[.description] = .string(description)
        meta[.localizedDescription] = .string(localizedDescription)
        
        if let localized = self as? LocalizedError {
            if let errorDescription = localized.errorDescription {
                meta[.localizedDescription] = .string(errorDescription)
            }
            
            if let failureReason = localized.failureReason {
                meta[.localizedFailureReason] = .string(failureReason)
            }
            
            if let recoverySuggestion = localized.recoverySuggestion {
                meta[.localizedRecoverySuggestion] = .string(recoverySuggestion)
            }
        }
        
        return meta.merging(errorUserInfo.metadata) { _, rhs in
            rhs
        }
    }
}

private extension Dictionary<String, Any> {
    var metadata: Logger.Metadata {
        var meta = Logger.Metadata()
        for (key, value) in self {
            switch value {
            case let array as [Any]:
                meta[key] = .array(array.metadata)
            case let dictionary as [String: Any]:
                meta[key] = .dictionary(dictionary.metadata)
            default:
                meta[key] = .string(String(describing: value))
            }
        }
        return meta
    }
}

private extension Array<Any> {
    var metadata: [Logger.MetadataValue] {
        var meta: [Logger.MetadataValue] = []
        for element in self {
            switch element {
            case let array as [Any]:
                meta.append(contentsOf: array.metadata)
            case let dictionary as [String: Any]:
                meta.append(.dictionary(dictionary.metadata))
            default:
                meta.append(.string(String(describing: element)))
            }
        }
        return meta
    }
}
