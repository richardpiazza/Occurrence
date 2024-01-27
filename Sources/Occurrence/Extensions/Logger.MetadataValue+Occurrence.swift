import Foundation
import Logging

extension Logger.MetadataValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dictionary = try? container.decode(Logger.Metadata.self) {
            self = .dictionary(dictionary)
        } else if let array = try? container.decode([Logger.MetadataValue].self) {
            self = .array(array)
        } else if let bool = try? container.decode(Bool.self) {
            self = .stringConvertible(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .stringConvertible(int)
        } else if let double = try? container.decode(Double.self) {
            self = .stringConvertible(double)
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
            if let bool = stringConvertible as? Bool {
                try container.encode(bool)
            } else if let int = stringConvertible as? Int {
                try container.encode(int)
            } else if let double = stringConvertible as? Double {
                try container.encode(double)
            } else {
                try container.encode(stringConvertible.description)
            }
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
    
    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
    
    var boolValue: Bool? {
        stringConvertibleValue as? Bool
    }
    
    var intValue: Int? {
        stringConvertibleValue as? Int
    }
    
    var doubleValue: Double? {
        stringConvertibleValue as? Double
    }
    
    #if compiler(>=5.7)
    var stringConvertibleValue: (CustomStringConvertible & Sendable)? {
        switch self {
        case .stringConvertible(let value):
            return value
        default:
            return nil
        }
    }
    #else
    var stringConvertibleValue: CustomStringConvertible? {
        switch self {
        case .stringConvertible(let value):
            return value
        default:
            return nil
        }
    }
    #endif
    
    var dictionaryValue: Logger.Metadata? {
        switch self {
        case .dictionary(let value):
            return value
        default:
            return nil
        }
    }
    
    var arrayValue: [Logger.Metadata.Value]? {
        switch self {
        case .array(let value):
            return value
        default:
            return nil
        }
    }
}
