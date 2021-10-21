import Foundation
import Logging

public extension Logger.Metadata {
    init(error: Error) {
        self = .init()
        self["localizedDescription"] = .string(error.localizedDescription)
    }
    
    init(localizedError error: LocalizedError) {
        self = .init()
        self["localizedDescription"] = .string(error.localizedDescription)
        
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
    
    init(decodingError error: DecodingError) {
        self = .init()
        self["localizedDescription"] = .string(error.localizedDescription)
        
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
    
    init(encodingError: EncodingError) {
        self = .init()
    }
}
