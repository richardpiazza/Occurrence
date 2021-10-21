import Foundation
import Logging

/// A source of logging data.
public protocol LogProvider {
    /// Consume a log entry.
    func log(_ entry: Logger.Entry)
    
    /// A collection of known `Logger.Subsystem`.
    ///
    /// - returns: A collection of known `Logger.Subsystem`.
    func subsystems() -> [Logger.Subsystem]
    
    /// Query the provider for entries.
    ///
    /// - parameters:
    ///   - filter: Any limitations that should be applied to the query.
    ///   - ascending: The date ordering that should be applied to the results.
    ///   - limit: Limit the number of results returned (0 = unlimited).
    /// - returns: A collection of `Logger.Entry` that match the given parameters.
    func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry]
    
    /// Removes entries from the storage
    ///
    /// - parameters:
    ///   - filter: Any limitations that should be applied to the query.
    func purge(matching filter: Logger.Filter?)
}

public extension LogProvider {
    func entries(_ filter: Logger.Filter? = nil, ascending: Bool = false, limit: UInt = 0) -> [Logger.Entry] {
        entries(matching: filter, ascending: ascending, limit: limit)
    }
    
    func purge(_ filter: Logger.Filter? = nil) {
        purge(matching: filter)
    }
}
