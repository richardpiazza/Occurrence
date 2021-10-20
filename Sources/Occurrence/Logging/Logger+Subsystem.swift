import Logging

public extension Logger {
    /// An individual component of an entire application.
    ///
    /// Typically a `Subsystem` will be defined on a per-package basis, using a reverse-dns style unique key.
    /// ```swift
    /// public extension Logger.Subsystem {
    ///     static let component: Logger.Subsystem = "tld.domain.package"
    /// }
    /// ```
    struct Subsystem: ExpressibleByStringLiteral, Codable, Hashable, Comparable, CustomStringConvertible {
        public let rawValue: String
        
        public var description: String { rawValue }
        
        public init(stringLiteral rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func < (lhs: Subsystem, rhs: Subsystem) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension Logger.Subsystem {
    /// The **Occurrence** package subsystem.
    static let occurrence: Self = "com.richardpiazza.occurrence"
}
