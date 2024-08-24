/// Configuration and feature extension to the `Occurrence` `LogHandler`.
public final class Incidence: Sendable {
    
    public static let instance = Incidence()
    
    public let outputToConsole: Bool
    public let outputToStream: Bool
    public let outputToStorage: Bool
    public let storage: LogStorage
    public let streamer: LogStreamer
    
    public init(
        outputToConsole: Bool = true,
        outputToStream: Bool = true,
        outputToStorage: Bool = true,
        storage: LogStorage = OccurrenceLogStorage(),
        streamer: LogStreamer = OccurrenceLogStreamer()
    ) {
        self.outputToConsole = outputToConsole
        self.outputToStream = outputToStream
        self.outputToStorage = outputToStorage
        self.storage = storage
        self.streamer = streamer
    }
}
