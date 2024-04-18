import Logging

public struct Occurrence: LogHandler {
    
    public struct Configuration {
        public var outputToConsole: Bool = true
        public var outputToStream: Bool = true
        public var outputToStorage: Bool = true
    }
    
    public static var configuration: Configuration = .init()
    private static var bootstrapped: Bool = false
    
    /// Bootstraps **Occurrence** in to `Logging.LoggingSystem`.
    ///
    /// This ensures that `Occurrence` only calls `LoggingSystem.bootstrap(Occurrence.init)` once.
    /// Repeated calls to `LoggingSystem.bootstrap()` is unpredictable and can lead to application crashes.
    ///
    /// - parameters:
    ///   - metadataProvider: The `MetadataProvider` used to inject runtime-generated metadata from the execution context.
    public static func bootstrap(metadataProvider: Logger.MetadataProvider? = nil) {
        guard !bootstrapped else {
            return
        }
        
        LoggingSystem.bootstrap(Occurrence.init, metadataProvider: metadataProvider)
        bootstrapped = true
    }
    
    public static let logStreamer: LogStreamer = OccurrenceLogStreamer()
    
    public static var logProvider: LogProvider = {
        do {
            #if canImport(CoreData)
            if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                return try CoreDataLogProvider()
            }
            #endif
            return try SQLiteLogProvider()
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }()
    
    public let label: String
    public var metadataProvider: Logger.MetadataProvider?
    public var metadata: Logger.Metadata = .init()
    public var logLevel: Logger.Level = .trace
    
    public init(label: String, metadataProvider: Logger.MetadataProvider?) {
        self.label = label
        self.metadataProvider = metadataProvider
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
        let joinedMetadata: Logger.Metadata?
        
        switch (metadata, metadataProvider?.get()) {
        case (.some(let instance), .some(let context)):
            joinedMetadata = instance.merging(context, uniquingKeysWith: { instanceValue, _ in instanceValue })
        case (.some(let instance), .none):
            joinedMetadata = instance
        case (.none, .some(let context)):
            joinedMetadata = context
        case (.none, .none):
            joinedMetadata = nil
        }
        
        let entry = Logger.Entry(
            subsystem: Logger.Subsystem(stringLiteral: label),
            level: level,
            message: message,
            metadata: joinedMetadata,
            source: source,
            file: file,
            function: function,
            line: line
        )
        
        if Self.configuration.outputToConsole {
            print(entry)
        }
        
        if Self.configuration.outputToStream {
            Self.logStreamer.log(entry)
        }
        
        if Self.configuration.outputToStorage {
            Self.logProvider.log(entry)
        }
    }
}
