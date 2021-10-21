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
    }
}
