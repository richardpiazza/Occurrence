import Foundation
import Logging
#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct CombineLogStreamer: LogStreamer {
    
    private var streamSubject: PassthroughSubject<Logger.Entry, Never> = .init()
    public var publisher: AnyPublisher<Logger.Entry, Never> { streamSubject.eraseToAnyPublisher() }
    
    public func log(_ entry: Logger.Entry) {
        streamSubject.send(entry)
    }
}
#endif
