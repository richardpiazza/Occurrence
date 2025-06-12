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
    struct Subsystem: Hashable, Sendable {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    init(_ subsystem: Subsystem, factory: Factory? = nil) {
        if let factory = factory {
            self = Logger(label: String(describing: subsystem), factory: factory)
        } else {
            self = Logger(label: String(describing: subsystem))
        }
    }
}

extension Logger.Subsystem: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Logger.Subsystem: Comparable {
    public static func < (lhs: Logger.Subsystem, rhs: Logger.Subsystem) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Logger.Subsystem: CustomStringConvertible {
    public var description: String { rawValue }
}

extension Logger.Subsystem: ExpressibleByStringLiteral {
    public init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Logger.Subsystem {
    /// The **Occurrence** package subsystem.
    static let occurrence: Self = "com.richardpiazza.occurrence"
}
