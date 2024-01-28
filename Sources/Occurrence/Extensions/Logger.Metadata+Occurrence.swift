import Foundation
import Logging

public extension Logger.Metadata {
    /// Reconstruct an `NSError` that may be represented in metadata.
    var nsError: NSError? {
        guard let domain = self[.domain]?.stringValue else {
            return nil
        }
        
        guard let code = self[.code]?.intValue else {
            return nil
        }
        
        let userInfo = ((self[.userInfo]?.dictionaryValue) ?? [:])
            .mapValues { $0.dictionaryRepresentableValue }
        
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}

@available(*, deprecated, message: "Prefer `LoggableError` metadata conformance.")
extension Logger.Metadata {
    public init(error: Error) {
        self = ["localizedDescription": .string(error.localizedDescription)]
    }
    
    public init(localizedError error: LocalizedError) {
        self = .init(error: error)
        
        if let errorDescription = error.errorDescription {
            self["errorDescription"] = .string(errorDescription)
        }
        if let failureReason = error.failureReason {
            self["failureReason"] = .string(failureReason)
        }
        if let recoverySuggestion = error.recoverySuggestion {
            self["recoverySuggestion"] = .string(recoverySuggestion)
        }
        if let helpAnchor = error.helpAnchor {
            self["helpAnchor"] = .string(helpAnchor)
        }
    }
    
    public init(decodingError error: DecodingError) {
        self = .init(error: error)
        
        switch error {
        case .typeMismatch(let type, let context):
            self["type"] = .string(String(describing: type))
            self["context"] = .string(context.debugDescription)
        case .valueNotFound(let type, let context):
            self["type"] = .string(String(describing: type))
            self["context"] = .string(context.debugDescription)
        case .keyNotFound(let codingKey, let context):
            self["codingKey"] = .string(codingKey.debugDescription)
            self["context"] = .string(context.debugDescription)
        case .dataCorrupted(let context):
            self["context"] = .string(context.debugDescription)
        @unknown default:
            break
        }
    }
    
    public init(encodingError error: EncodingError) {
        self = .init(error: error)
        
        switch error {
        case .invalidValue(let type, let context):
            self["type"] = .string(String(describing: type))
            self["context"] = .string(context.debugDescription)
        @unknown default:
            break
        }
    }
}

@available(*, deprecated, message: "Prefer `LoggableError` metadata conformance.")
extension Logger.Metadata {
    public init(_ error: Error) {
        if let encodingError = error as? EncodingError {
            self = .init(encodingError: encodingError)
        } else if let decodingError = error as? DecodingError {
            self = .init(decodingError: decodingError)
        } else if let localizedError = error as? LocalizedError {
            self = .init(localizedError: localizedError)
        } else {
            self = .init(error: error)
        }
    }
}
