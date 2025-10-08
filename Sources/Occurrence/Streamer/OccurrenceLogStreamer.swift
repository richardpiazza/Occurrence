import Foundation
import Logging
#if canImport(Combine)
import Combine
#endif

class OccurrenceLogStreamer: LogStreamer {

    private var continuation: AsyncStream<Logger.Entry>.Continuation?

    var stream: AsyncStream<Logger.Entry> {
        continuation?.finish()
        let sequence = AsyncStream<Logger.Entry>.makeStream()
        continuation = sequence.continuation
        return sequence.stream
    }

    #if canImport(Combine)
    private var streamSubject: PassthroughSubject<Logger.Entry, Never> = .init()
    var publisher: AnyPublisher<Logger.Entry, Never> { streamSubject.eraseToAnyPublisher() }
    #endif

    func log(_ entry: Logger.Entry) {
        continuation?.yield(entry)
        #if canImport(Combine)
        streamSubject.send(entry)
        #endif
    }
}
