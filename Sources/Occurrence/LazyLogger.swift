import Foundation
import Logging

/// Provides an inline way to reference a lazy-loaded instance of `Logger`.
///
/// A `LazyLogger` is typically used in the following manner:
/// ```
/// @LazyLogger(.occurrence) var logger: Logger
/// ```
@propertyWrapper public struct LazyLogger {
    
    private let subsystem: Logger.Subsystem
    private let factory: Logger.Factory?
    
    private lazy var logger = Logger(subsystem, factory: factory)
    
    public var wrappedValue: Logger {
        mutating get {
            logger
        }
    }
    
    public init(_ subsystem: Logger.Subsystem, factory: Logger.Factory? = nil) {
        self.subsystem = subsystem
        self.factory = factory
    }
}
