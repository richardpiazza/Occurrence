import Logging
import AsyncPlus
#if canImport(Combine)
@preconcurrency import Combine
#endif

public struct OccurrenceLogStreamer: LogStreamer {
    
    #if canImport(Combine)
    private let publisherSubject = PassthroughSubject<Logger.Entry, Never>()
    public var publisher: AnyPublisher<Logger.Entry, Never> { publisherSubject.eraseToAnyPublisher() }
    #endif
    
    private let streamSubject = PassthroughAsyncSubject<Logger.Entry>()
    
    public init() {
    }
    
    public func stream() async -> AsyncStream<Logger.Entry> {
        await streamSubject.sink()
    }
    
    public func log(_ entry: Logger.Entry) {
        Task {
            await streamSubject.yield(entry)
        }
        #if canImport(Combine)
        publisherSubject.send(entry)
        #endif
    }
    
    public func terminate() {
        Task {
            await streamSubject.finish()
        }
        #if canImport(Combine)
        publisherSubject.send(completion: .finished)
        #endif
    }
}
