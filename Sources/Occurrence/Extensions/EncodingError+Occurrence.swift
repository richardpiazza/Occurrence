import Foundation
import Logging

extension EncodingError: @retroactive CustomNSError, LoggableError {
    public static var errorDomain: String { "SwiftEncodingErrorDomain" }

    public var errorCode: Int {
        switch self {
        case .invalidValue: return 0
        @unknown default: return -1
        }
    }

    public var errorUserInfo: [String: Any] {
        let description: String

        switch self {
        case .invalidValue(let value, let context):
            let path = context.codingPath.map(\.stringValue)
            description = "Encoding (Invalid Value) - Value: \(value), Context: \(context.debugDescription) \(path)"
        @unknown default:
            description = "Encoding (Unknown) - \(localizedDescription)"
        }

        return [Logger.MetadataKey.description.stringValue: description]
    }
}
