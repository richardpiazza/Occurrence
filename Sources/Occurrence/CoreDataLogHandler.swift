import Foundation
import Logging
#if canImport(CoreData)
import CoreData

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public struct CoreDataLogHandler: LogHandler {
    
    public let label: String
    public var metadata: Logger.Metadata = .init()
    public var logLevel: Logger.Level = .trace
    
    private lazy var persistentContainer: NSPersistentContainer = {
        preconditionFailure()
    }()
    
    public init(label: String) {
        self.label = label
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        
    }
}
#endif
