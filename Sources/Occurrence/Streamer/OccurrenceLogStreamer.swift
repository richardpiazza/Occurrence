import Foundation
import Logging
#if canImport(Combine)
import Combine
#endif

class OccurrenceLogStreamer: LogStreamer {
    
    private var asyncStream: AsyncStream<Logger.Entry>?
    private var continuation: AsyncStream<Logger.Entry>.Continuation?
    
    var stream: AsyncStream<Logger.Entry> {
        continuation?.finish()
        let _stream: AsyncStream<Logger.Entry>
        #if swift(>=5.8)
        let sequence = AsyncStream<Logger.Entry>.makeStream()
        _stream = sequence.stream
        asyncStream = _stream
        continuation = sequence.continuation
        #else
        _stream = AsyncStream<Logger.Entry> { token in
            continuation = token
        }
        asyncStream = _stream
        #endif
        
        return _stream
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
