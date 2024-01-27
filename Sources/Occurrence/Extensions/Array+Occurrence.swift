import Foundation
import Logging

internal extension Array<Any> {
    var metadataValues: [Logger.MetadataValue] {
        var values: [Logger.MetadataValue] = []
        
        for element in self {
            switch element {
            case let string as String:
                values.append(.string(string))
            #if compiler(>=5.7)
            case let stringConvertible as (CustomStringConvertible & Sendable):
                values.append(.stringConvertible(stringConvertible))
            #else
            case let stringConvertible as CustomStringConvertible:
                values.append(.stringConvertible(stringConvertible))
            #endif
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
