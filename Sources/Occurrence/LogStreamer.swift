import Logging
#if canImport(Combine)
import Combine
#endif

public protocol LogStreamer: Sendable {
    #if canImport(Combine)
    /// Publisher which emits log entries.
    var publisher: AnyPublisher<Logger.Entry, Never> { get }
    #endif
    
    /// `AsyncStream` which emits log entries.
    func stream() async -> AsyncStream<Logger.Entry>
    
    /// Consume a log entry.
    func log(_ entry: Logger.Entry)
}
