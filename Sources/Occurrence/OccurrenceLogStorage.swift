import Logging

/// A `LogStorage` suitable for storing logs on the current platform.
///
/// By default, this will be a `CoreDataLogStorage` when available,
/// otherwise a `SQLiteLogStorage`.
public struct OccurrenceLogStorage: LogStorage {
    
    private var logStorage: LogStorage?
    
    public init() {
        do {
            #if canImport(CoreData)
            if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                logStorage = try CoreDataLogStorage()
            } else {
                logStorage = try SQLiteLogStorage()
            }
            #else
            logStorage = try SQLiteLogStorage()
            #endif
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
    
    public func log(_ entry: Logger.Entry) {
        logStorage?.log(entry)
    }
    
    public func subsystems() -> [Logger.Subsystem] {
        logStorage?.subsystems() ?? []
    }
    
    public func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        logStorage?.entries(matching: filter, ascending: ascending, limit: limit) ?? []
    }
    
    public func purge(matching filter: Logger.Filter?) {
        logStorage?.purge(matching: filter)
    }
}
