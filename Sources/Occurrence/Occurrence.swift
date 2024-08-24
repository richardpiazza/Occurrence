import Logging

public struct Occurrence: LogHandler {

    private actor Bootstrapper {
        var bootstrapped: Bool = false
        
        func bootstrap(metadataProvider: Logger.MetadataProvider? = nil) {
            guard !bootstrapped else {
                return
            }
            
            bootstrapped = true
            LoggingSystem.bootstrap(Occurrence.init, metadataProvider: metadataProvider)
        }
    }
    
    private static let bootstrapper = Bootstrapper()
    
    /// Bootstraps **Occurrence** in to `Logging.LoggingSystem`.
    ///
    /// > bootstrap is a one-time configuration function which globally selects the desired logging backend implementation.
    ///
    /// - warning: Repeated calls to `LoggingSystem.bootstrap()` will throw an exception.
    /// - parameters:
    ///   - metadataProvider: The `MetadataProvider` used to inject runtime-generated metadata from the execution context.
    public static func bootstrap(metadataProvider: Logger.MetadataProvider? = nil) {
        Task {
            await bootstrapper.bootstrap(metadataProvider: metadataProvider)
        }
    }
    
    public let label: String
    public var metadataProvider: Logger.MetadataProvider?
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .trace

    public var incidence: Incidence = .instance
    
    @Sendable public init(
        label: String,
        metadataProvider: Logger.MetadataProvider?
    ) {
        self.label = label
        self.metadataProvider = metadataProvider
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set(newValue) { metadata[key] = newValue }
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let joinedMetadata: Logger.Metadata? = switch (metadata, metadataProvider?.get()) {
        case (.some(let instance), .some(let context)):
            instance.merging(context, uniquingKeysWith: { instanceValue, _ in instanceValue })
        case (.some(let instance), .none):
            instance
        case (.none, .some(let context)):
            context
        case (.none, .none):
            nil
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

        if incidence.outputToConsole {
            print(entry)
        }
        
        if incidence.outputToStream {
            incidence.streamer.log(entry)
        }
        
        if incidence.outputToStorage {
            incidence.storage.log(entry)
        }
    }
}
