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
            case .domain: "domain"
            case .code: "code"
            case .userInfo: "userInfo"
            case .localizedDescription: NSLocalizedDescriptionKey
            case .localizedFailureReason: NSLocalizedFailureReasonErrorKey
            case .localizedRecoverySuggestion: NSLocalizedRecoverySuggestionErrorKey
            case .localizedHelpAnchor: NSHelpAnchorErrorKey
            case .localizedRecoveryOptions: NSLocalizedRecoveryOptionsErrorKey
            case .description: "description"
            case .file: "file"
            case .function: "function"
            case .line: "line"
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
