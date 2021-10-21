import Logging

public struct Occurrence: LogHandler {
    
    public struct Configuration {
        public var outputToConsole: Bool = true
        public var outputToPublisher: Bool = true
        public var outputToStorage: Bool = true
    }
    
    public static var configuration: Configuration = .init()
    private static var bootstrapped: Bool = false
    
    /// Bootstraps **Occurrence** in to `Logging.LoggingSystem`.
    ///
    /// This ensures that `Occurrence` only calls `LoggingSystem.bootstrap(Occurrence.init)` once.
    /// Repeated calls to `LoggingSystem.bootstrap()` is unpredictable and can lead to application crashes.
    public static func bootstrap() {
        guard !bootstrapped else {
            return
        }
        
        LoggingSystem.bootstrap(Occurrence.init)
        bootstrapped = true
    }
    
    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static let logStreamer: LogStreamer = CombineLogStreamer()
    #endif
    
    #if canImport(CoreData)
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    public static let logProvider: LogProvider = CoreDataLogProvider()
    #else
    public static let logProvider: LogProvider = SQLiteLogProvider()
    #endif
    
    public let label: String
    public var metadata: Logger.Metadata = .init()
    public var logLevel: Logger.Level = .trace
    
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
        let entry = Logger.Entry(
            subsystem: Logger.Subsystem(stringLiteral: label),
            level: level,
            message: message,
            metadata: metadata,
            source: source,
            file: file,
            function: function,
            line: line
        )
        
        if Self.configuration.outputToConsole {
            print(entry)
        }
        
        if Self.configuration.outputToPublisher {
            #if canImport(Combine)
            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                Self.logStreamer.log(entry)
            }
            #endif
        }
        
        if Self.configuration.outputToStorage {
            #if canImport(CoreData)
            if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                Self.logProvider.log(entry)
            }
            #else
            Self.logProvider.log(entry)
            #endif
        }
    }
}
