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
