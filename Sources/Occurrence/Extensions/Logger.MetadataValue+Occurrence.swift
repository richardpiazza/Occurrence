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
