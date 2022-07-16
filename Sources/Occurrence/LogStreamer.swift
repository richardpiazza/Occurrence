import Foundation
import Logging
#if canImport(Combine)
import Combine
#endif

public protocol LogStreamer {
    /// `AsyncStream` which emits log entries.
    ///
    /// Due to limitations with the underlying `AsyncSequence` implementation, only a single receiver can await elements.
    /// Each access with _finish_ an existing stream and return a fresh stream.
    var stream: AsyncStream<Logger.Entry> { get }
    
    #if canImport(Combine)
    /// Publisher which emits log entries.
    var publisher: AnyPublisher<Logger.Entry, Never> { get }
    #endif
    
    /// Consume a log entry.
    func log(_ entry: Logger.Entry)
}
