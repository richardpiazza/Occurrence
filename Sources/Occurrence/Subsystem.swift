import Foundation
import Logging

/// Provides an inline way to reference a labeled instance of `Logger`.
///
/// A `Subsystem` is typically used in the following manner:
/// ```
/// @Subsystem(.occurrence) private var logger: Logger
/// ```
@propertyWrapper public struct Subsystem {
    public typealias Factory = (String) -> LogHandler
    
    public let wrappedValue: Logger
    
    public init(_ subsystem: Logger.Subsystem, factory: Factory? = nil) {
        if let factory = factory {
            self.wrappedValue = Logger(label: subsystem.description, factory: factory)
        } else {
            self.wrappedValue = Logger(label: subsystem.description)
        }
    }
}
