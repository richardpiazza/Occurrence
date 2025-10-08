import Foundation
import Logging

extension Logger.Message: @retroactive Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = .init(stringLiteral: value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
