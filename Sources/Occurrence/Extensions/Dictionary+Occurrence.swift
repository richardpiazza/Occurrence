import Logging

public extension Dictionary<String, Any> {
    /// Redacts keys within the instance with a replacement value.
    ///
    /// The provided `keyPaths` should be in a dotted notation to recursively redact entries. For example:
    /// ```swift
    /// let dictionary: [String: Any] = [
    ///   "a": "example",
    ///   "b": 2,
    ///   "c": [
    ///     "d": "secret"
    ///     "e": "not"
    ///   ]
    /// ]
    ///
    /// let result = dictionary.redacting(keyPaths: ["b", "c.d"])
    /// /*
    /// [
    ///   "a": "example",
    ///   "b": "<REDACTED>",
    ///   "c": [
    ///     "d": "<REDACTED>",
    ///     "e": "not"
    ///   ]
    /// ]
    /// */
    /// ```
    func redacting(keyPaths: [String] = [], replacement: String = "<REDACTED>") -> Self {
        var dictionary = self
        
        for keyPath in keyPaths {
            let split = keyPath.split(separator: ".", maxSplits: 1)
            let key = String(split[0])
            guard var value = dictionary[key] else {
                continue
            }

            if split.count > 1 {
                let subPath = String(split[1])
                if let subDictionary = value as? [String: Any] {
                    value = subDictionary.redacting(keyPaths: [subPath], replacement: replacement)
                }
            } else {
                value = replacement
            }

            dictionary[key] = value
        }
        
        return dictionary
    }
}

internal extension Dictionary<String, Any> {
    var metadata: Logger.Metadata {
        var meta: Logger.Metadata = [:]
        
        for (key, value) in self {
            switch value {
            case let dictionary as [String: Any]:
                meta[key] = .dictionary(dictionary.metadata)
            case let array as [Any]:
                meta[key] = .array(array.metadataValues)
            case let string as String:
                meta[key] = .string(string)
            #if compiler(>=5.7)
            case let stringConvertible as (CustomStringConvertible & Sendable):
                meta[key] = .stringConvertible(stringConvertible)
            #else
            case let stringConvertible as CustomStringConvertible:
                meta[key] = .stringConvertible(stringConvertible)
            #endif
            default:
                meta[key] = .string(String(describing: value))
            }
        }
        
        return meta
    }
}
