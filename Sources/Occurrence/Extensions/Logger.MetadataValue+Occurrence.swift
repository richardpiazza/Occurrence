import Foundation
import Logging

extension Logger.MetadataValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dictionary = try? container.decode(Logger.Metadata.self) {
            self = .dictionary(dictionary)
        } else if let array = try? container.decode([Logger.MetadataValue].self) {
            self = .array(array)
        } else {
            let string = try container.decode(String.self)
            self = .string(string)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .stringConvertible(let stringConvertible):
            try container.encode(stringConvertible.description)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        case .array(let array):
            try container.encode(array)
        }
    }
}

public extension Logger.MetadataValue {
    init(_ any: Any) {
        switch any {
        case let value as String:
            self = .string(value)
        case let value as Bool:
            self = .stringConvertible(value)
        case let value as Int:
            self = .stringConvertible(value)
        case let value as Double:
            self = .stringConvertible(value)
        case let value as [CustomStringConvertible & Sendable]:
            self = .array(value.map { .stringConvertible($0) })
        case let value as [String: CustomStringConvertible & Sendable]:
            self = .dictionary(value.mapValues { .stringConvertible($0) })
        default:
            self = .string(String(describing: any))
        }
    }
}
