import Foundation
import Logging

public extension Logger {
    /// Log a message along with a `LoggableError` that provides `Logger.Metadata` in the entry.
    ///
    /// - parameters:
    ///    - level: The `Logger.Level` for which to log the `message`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - error: `LoggableError` providing `Metadata` to the entry.
    ///    - redacting: Optional keys that will be used to redact sensitive 'userInfo' of the error.
    ///    - source: The source to which this log messages originates.
    ///    - file: The file to which this log message originates from.
    ///    - function: The function to which this log message originates.
    ///    - line: The line to which this log message originates.
    ///  - returns: The `LoggableError` that was logged as a convenience to `throw` or reuse.
    @discardableResult func log<T: LoggableError>(
        level: Logger.Level,
        _ message: @autoclosure () -> Logger.Message,
        error: T,
        redacting keyPaths: [String] = [],
        source: @autoclosure () -> String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> T {
        log(
            level: level,
            message(),
            metadata: error.metadata(redactingUserInfo: keyPaths),
            source: source(),
            file: file,
            function: function,
            line: line
        )
        
        return error
    }
    
    /// Log a message along with a dictionary that will be converted to a Metadata representation.
    ///
    /// - parameters:
    ///    - level: The `Logger.Level` for which to log the `message`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - dictionary: Dictionary that will be represented in the `Metadata`.
    ///    - redacting: Optional keys that will be used to redact sensitive key paths.
    ///    - source: The source to which this log messages originates.
    ///    - file: The file to which this log message originates from.
    ///    - function: The function to which this log message originates.
    ///    - line: The line to which this log message originates.
    func log(
        level: Logger.Level,
        _ message: @autoclosure () -> Logger.Message,
        dictionary: [String: Any],
        redacting keyPaths: [String] = [],
        source: @autoclosure () -> String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: level,
            message(),
            metadata: dictionary.redacting(keyPaths: keyPaths).metadata,
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }
    
    /// Log a message along with binary data (Representing a JSON object) that will be converted to a `Metadata`.
    ///
    /// - parameters:
    ///    - level: The `Logger.Level` for which to log the `message`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - data: Data that will be interpreted as JSON and represented in the `Metadata`.
    ///    - redacting: Optional keys that will be used to redact sensitive key paths.
    ///    - source: The source to which this log messages originates.
    ///    - file: The file to which this log message originates from.
    ///    - function: The function to which this log message originates.
    ///    - line: The line to which this log message originates.
    func log(
        level: Logger.Level,
        _ message: @autoclosure () -> Logger.Message,
        data: Data,
        redacting keyPaths: [String] = [],
        source: @autoclosure () -> String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            log(level: level, message(), source: source(), file: file, function: function, line: line)
            return
        }
        
        if let dictionary = jsonObject as? [String: Any] {
            log(level: level, message(), dictionary: dictionary, redacting: keyPaths, source: source(), file: file, function: function, line: line)
        } else if let array = jsonObject as? [[String: Any]] {
            var metadata: Logger.Metadata = [:]
            for (index, element) in array.enumerated() {
                metadata[String(describing: index)] = .dictionary(element.metadata)
            }
            log(level: level, message(), metadata: metadata, source: source(), file: file, function: function, line: line)
        } else {
            log(level: level, message(), source: source(), file: file, function: function, line: line)
        }
    }
    
    /// Log a message along with an `Encodable` object that will be converted to a Metadata representation.
    ///
    /// - parameters:
    ///    - level: The `Logger.Level` for which to log the `message`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - encodable: Object that will be interpreted and represented in the `Metadata`.
    ///    - redacting: Optional keys that will be used to redact sensitive key paths.
    ///    - source: The source to which this log messages originates.
    ///    - file: The file to which this log message originates from.
    ///    - function: The function to which this log message originates.
    ///    - line: The line to which this log message originates.
    func log<T: Encodable>(
        level: Logger.Level,
        _ message: @autoclosure () -> Logger.Message,
        encodable: T,
        redacting keyPaths: [String] = [],
        source: @autoclosure () -> String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard let data = try? JSONEncoder().encode(encodable) else {
            log(level: level, message(), source: source(), file: file, function: function, line: line)
            return
        }
        
        log(level: level, message(), data: data, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Trace
public extension Logger {
    @discardableResult func trace<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .trace, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func trace(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .trace, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func trace(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .trace, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func trace<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .trace, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Debug
public extension Logger {
    @discardableResult func debug<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .debug, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func debug(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .debug, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func debug(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .debug, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func debug<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .debug, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Info
public extension Logger {
    @discardableResult func info<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .info, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func info(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .info, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func info(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .info, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func info<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .info, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Notice
public extension Logger {
    @discardableResult func notice<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .notice, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func notice(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .notice, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func notice(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .notice, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func notice<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .notice, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Warning
public extension Logger {
    @discardableResult func warning<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .warning, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func warning(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .warning, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func warning(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .warning, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func warning<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .warning, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Error
public extension Logger {
    @discardableResult func error<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .error, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func error(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .error, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func error(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .error, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func error<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .error, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}

// MARK: - Critical
public extension Logger {
    @discardableResult func critical<T: LoggableError>(_ message: @autoclosure () -> Logger.Message, error: T, redacting keyPaths: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) -> T {
        log(level: .critical, message(), error: error, redacting: keyPaths, source: source(), file: file, function: function, line: line)
    }
    
    func critical(_ message: @autoclosure () -> Logger.Message, dictionary: [String: Any], redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .critical, message(), dictionary: dictionary, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func critical(_ message: @autoclosure () -> Logger.Message, data: Data, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .critical, message(), data: data, redacting: keys, source: source(), file: file, function: function, line: line)
    }
    
    func critical<T: Encodable>(_ message: @autoclosure () -> Logger.Message, encodable: T, redacting keys: [String] = [], source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .critical, message(), encodable: encodable, redacting: keys, source: source(), file: file, function: function, line: line)
    }
}
