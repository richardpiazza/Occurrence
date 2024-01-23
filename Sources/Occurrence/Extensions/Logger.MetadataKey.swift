import Foundation
import Logging

public extension Logger {
    enum MetadataKey {
        case domain
        case code
        case file
        case function
        case line
        case localizedDescription
        case localizedFailureReason
        case localizedRecoverySuggestion
        
        public var value: String {
            switch self {
            case .domain: return "domain"
            case .code: return "code"
            case .file: return "file"
            case .function: return "function"
            case .line: return "line"
            case .localizedDescription: return NSLocalizedDescriptionKey
            case .localizedFailureReason: return NSLocalizedFailureReasonErrorKey
            case .localizedRecoverySuggestion: return NSLocalizedRecoverySuggestionErrorKey
            }
        }
    }
}

extension Logger.Metadata {
    subscript(_ key: Logger.MetadataKey) -> Value? {
        get {
            self[key.value]
        }
        set {
            self[key.value] = newValue
        }
    }
}
