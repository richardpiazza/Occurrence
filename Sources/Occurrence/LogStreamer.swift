import Foundation
import Logging

public protocol LogStreamer: Sendable {
    /// `AsyncStream` which emits log entries.
    var stream: AsyncStream<Logger.Entry> { get }

    /// Consume a log entry.
    func log(_ entry: Logger.Entry)
}
