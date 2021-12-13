import Foundation
import Logging

public extension Logger {
    struct Entry: Codable, CustomStringConvertible {
        
        public static var gmtDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS'Z'"
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
            metadata: Logger.Metadata?,
            source: String,
            file: String,
            function: String,
            line: UInt
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
            let _file = URL(fileURLWithPath: file).lastPathComponent
            let output = "[\(_date) \(level) | \(subsystem) | \(source) \(_file) | \(function) \(line)] \(message)"
            if let metadata = metadata {
                return "\(output)\n\(metadata)"
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
