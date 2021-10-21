import Foundation
import Logging

class SQLiteLogProvider: LogProvider {
    
    public init() {
        
    }
    
    public func log(_ entry: Logger.Entry) {
        
    }
    
    public func subsystems() -> [Logger.Subsystem] {
        []
    }
    
    public func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        []
    }
    
    public func purge(matching filter: Logger.Filter?) {
        
    }
}
