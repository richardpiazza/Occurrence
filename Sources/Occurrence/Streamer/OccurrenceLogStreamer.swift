import Foundation
import Logging
#if canImport(Synchronization)
import Synchronization
#else
import Mutex
#endif

final class OccurrenceLogStreamer: LogStreamer {

    private let subscribers: Mutex<[UUID: AsyncStream<Logger.Entry>.Continuation]> = Mutex([:])

    var stream: AsyncStream<Logger.Entry> {
        let id = UUID()
        let sequence = AsyncStream<Logger.Entry>.makeStream()
        sequence.continuation.onTermination = { _ in
            self.unsubscribe(id)
        }
        subscribers.withLock {
            $0[id] = sequence.continuation
        }
        return sequence.stream
    }

    func log(_ entry: Logger.Entry) {
        let subscriptions = subscribers.withLock { $0 }
        for continuation in subscriptions.values {
            continuation.yield(entry)
        }
    }

    private func unsubscribe(_ id: UUID) {
        subscribers.withLock {
            $0[id] = nil
        }
    }
}
