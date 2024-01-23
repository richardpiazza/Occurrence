import Foundation
import Logging

public extension Logger {
    enum MetadataKey: CodingKey {
        case domain
        case code
        case description
        case file
        case function
        case line
        case localizedDescription
        case localizedFailureReason
        case localizedRecoverySuggestion
        
        public var stringValue: String {
            switch self {
            case .domain: return "domain"
            case .code: return "code"
            case .description: return "description"
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
            self[key.stringValue]
        }
        set {
            self[key.stringValue] = newValue
        }
    }
}
