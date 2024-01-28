import Foundation
import Logging

public extension Logger {
    enum MetadataKey: CodingKey {
        // Primary
        case domain
        case code
        case userInfo
        // Secondary
        case localizedDescription
        case localizedFailureReason
        case localizedRecoverySuggestion
        case localizedHelpAnchor
        case localizedRecoveryOptions
        // Additional keys
        case description
        case file
        case function
        case line
        
        public var stringValue: String {
            switch self {
            case .domain: return "domain"
            case .code: return "code"
            case .userInfo: return "userInfo"
            case .localizedDescription: return NSLocalizedDescriptionKey
            case .localizedFailureReason: return NSLocalizedFailureReasonErrorKey
            case .localizedRecoverySuggestion: return NSLocalizedRecoverySuggestionErrorKey
            case .localizedHelpAnchor: return NSHelpAnchorErrorKey
            case .localizedRecoveryOptions: return NSLocalizedRecoveryOptionsErrorKey
            case .description: return "description"
            case .file: return "file"
            case .function: return "function"
            case .line: return "line"
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
