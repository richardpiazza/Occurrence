import Logging

public extension Logger {
    typealias Factory = (String) -> LogHandler
    
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
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(String.self)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        public static func < (lhs: Subsystem, rhs: Subsystem) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    init(_ subsystem: Subsystem, factory: Factory? = nil) {
        if let factory = factory {
            self = Logger(label: subsystem.description, factory: factory)
        } else {
            self = Logger(label: subsystem.description)
        }
    }
}

extension Logger.Subsystem {
    /// The **Occurrence** package subsystem.
    static let occurrence: Self = "com.richardpiazza.occurrence"
}
