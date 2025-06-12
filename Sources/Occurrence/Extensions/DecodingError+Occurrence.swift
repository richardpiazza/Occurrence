import Foundation
import Logging

extension DecodingError: @retroactive CustomNSError, LoggableError {
    public static var errorDomain: String { "SwiftDecodingErrorDomain" }

    public var errorCode: Int {
        switch self {
        case .typeMismatch: return 0
        case .valueNotFound: return 1
        case .keyNotFound: return 2
        case .dataCorrupted: return 3
        @unknown default: return -1
        }
    }

    public var errorUserInfo: [String: Any] {
        let description: String

        switch self {
        case .typeMismatch(let any, let context):
            let path = context.codingPath.map(\.stringValue)
            description = "Decoding (Type Mismatch) - Type: \(String(describing: any)), Context: \(context.debugDescription) \(path)"
        case .valueNotFound(let any, let context):
            let path = context.codingPath.map(\.stringValue)
            description = "Decoding (Value Not Found) - Type: \(String(describing: any)), Context: \(context.debugDescription) \(path)"
        case .keyNotFound(let codingKey, let context):
            let path = context.codingPath.map(\.stringValue)
            description = "Decoding (Key Not Found) - Key: \(codingKey), Context: \(context.debugDescription) \(path)"
        case .dataCorrupted(let context):
            let path = context.codingPath.map(\.stringValue)
            description = "Decoding (Data Corrupted) - Context: \(context.debugDescription) \(path)"
        @unknown default:
            description = "Decoding (Unknown) - \(localizedDescription)"
        }

        return [Logger.MetadataKey.description.stringValue: description]
    }
}
