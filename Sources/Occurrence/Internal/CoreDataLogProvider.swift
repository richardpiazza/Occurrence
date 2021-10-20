import Foundation
import Logging
#if canImport(CoreData)
import CoreData

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
class CoreDataLogProvider: LogProvider {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        preconditionFailure()
    }()
    
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
#endif
