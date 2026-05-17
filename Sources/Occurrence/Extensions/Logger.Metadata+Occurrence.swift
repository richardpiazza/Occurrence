import Foundation
import Logging

public extension Logger.Metadata {
    /// Reconstruct an `NSError` that may be represented in metadata.
    var nsError: NSError? {
        guard let domain = self[.domain]?.stringValue else {
            return nil
        }

        guard let code = self[.code]?.intValue else {
            return nil
        }

        let userInfo = ((self[.userInfo]?.dictionaryValue) ?? [:])
            .mapValues { $0.dictionaryRepresentableValue }

        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}

extension Logger.Metadata {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    var prettyDescription: String {
        guard let data = try? Self.encoder.encode(self) else {
            return ""
        }

        return String(decoding: data, as: UTF8.self)
    }
}
