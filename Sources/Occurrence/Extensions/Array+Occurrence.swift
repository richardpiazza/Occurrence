import Foundation
import Logging

extension [Any] {
    var metadataValues: [Logger.MetadataValue] {
        var values: [Logger.MetadataValue] = []

        for element in self {
            switch element {
            case let string as String:
                values.append(.string(string))
            case let stringConvertible as (any CustomStringConvertible & Sendable):
                values.append(.stringConvertible(stringConvertible))
            case let dictionary as [String: Any]:
                values.append(.dictionary(dictionary.metadata))
            case let array as [Any]:
                values.append(.array(array.metadataValues))
            default:
                values.append(.string(String(describing: element)))
            }
        }

        return values
    }
}
