import Foundation
import Logging

public extension Logger {
    struct Entry: Codable, CustomStringConvertible {
        
        public static var gmtDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        public let date: Date
        public let subsystem: Subsystem
        public let level: Logger.Level
        public let message: Logger.Message
        public let metadata: Logger.Metadata?
        public let source: String
        public let file: String
        public let function: String
        public let line: UInt
    
        public init(
            date: Date = Date(),
            subsystem: Subsystem,
            level: Logger.Level,
            message: Logger.Message,
            metadata: Logger.Metadata? = nil,
            source: String,
            file: String = #fileID,
            function: String = #function,
            line: UInt = #line
        ) {
            self.date = date
            self.subsystem = subsystem
            self.level = level
            self.message = message
            self.metadata = metadata
            self.source = source
            self.file = file
            self.function = function
            self.line = line
        }
        
        public var description: String {
            let _date = Self.gmtDateFormatter.string(from: date)
            let sourceFile = [source, fileName].filter { !$0.isEmpty }.joined(separator: " ")
            let output = "[\(_date) \(level) | \(subsystem) | \(sourceFile) | \(function) \(line)] \(message)"
            if let metadata = metadata {
                let sortedMetadata = metadata.sorted(by: { $0.key < $1.key })
                let values = sortedMetadata.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
                return "\(output) { \(values) }"
            } else {
                return output
            }
        }
        
        public func matchesFilter(_ filter: Logger.Filter) -> Bool {
            switch filter {
            case .subsystem(let subsystem):
                return self.subsystem == subsystem
            case .level(let level):
                return self.level == level
            case .message(let message):
                return self.message.description.contains(message)
            case .source(let source):
                return self.source.contains(source)
            case .file(let file):
                return self.file.contains(file)
            case .function(let function):
                return self.function.contains(function)
            case .period(let start, let end):
                return (date >= start) && (date <= end)
            case .and(let filters):
                return !filters.map({ matchesFilter($0) }).contains(false)
            case .or(let filters):
                return filters.map({ matchesFilter($0) }).contains(true)
            case .not(let filters):
                return !filters.map({ matchesFilter($0) }).contains(true)
            }
        }
    }
}

public extension Logger.Entry {
    /// Attempts to extract only the last path component of the `file`
    var fileName: String {
        URL(fileURLWithPath: file).lastPathComponent
    }
}
