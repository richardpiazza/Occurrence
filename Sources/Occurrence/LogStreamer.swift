import Foundation
import Logging
#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol LogStreamer {
    var publisher: AnyPublisher<Logger.Entry, Never> { get }
    
    func log(_ entry: Logger.Entry)
}
#endif
