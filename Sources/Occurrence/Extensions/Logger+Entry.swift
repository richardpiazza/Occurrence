import Foundation
import Logging

public extension Logger {
    struct Entry: Codable, Sendable {

        #if canImport(ObjectiveC)
        @available(*, deprecated)
        public static let gmtDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        #endif

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
            line: UInt = #line,
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

        public func matchesFilter(_ filter: Logger.Filter) -> Bool {
            switch filter {
            case .subsystem(let subsystem):
                self.subsystem == subsystem
            case .level(let level):
                self.level == level
            case .message(let message):
                self.message.description.contains(message)
            case .source(let source):
                self.source.contains(source)
            case .file(let file):
                self.file.contains(file)
            case .function(let function):
                self.function.contains(function)
            case .period(let start, let end):
                (date >= start) && (date <= end)
            case .and(let filters):
                !filters.map { matchesFilter($0) }.contains(false)
            case .or(let filters):
                filters.map { matchesFilter($0) }.contains(true)
            case .not(let filters):
                !filters.map { matchesFilter($0) }.contains(true)
            }
        }

        var descriptionPrefix: String {
            let sourceFile = [source, fileName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")

            return "[\(date.formatted(Self.formatStyle)) \(level.fancyDescription) | \(subsystem) | \(sourceFile) | \(function) \(line)]"
        }
    }
}

extension Logger.Entry: CustomDebugStringConvertible {
    public var debugDescription: String {
        let output = "\(descriptionPrefix) \(message)"

        guard let metadata, !metadata.isEmpty else {
            return output
        }

        return "\(output)\n\(metadata.prettyDescription)"
    }
}

extension Logger.Entry: CustomStringConvertible {
    public var description: String {
        let output = "\(descriptionPrefix) \(message)"

        guard let metadata, !metadata.isEmpty else {
            return output
        }

        let sortedMetadata = metadata
            .sorted(by: { $0.key < $1.key })

        let values = sortedMetadata
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")

        return "\(output) { \(values) }"
    }
}

public extension Logger.Entry {
    /// Format style that uses: `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`
    static var formatStyle: Date.ISO8601FormatStyle {
        .iso8601
            .month()
            .day()
            .year()
            .dateSeparator(.dash)
            .time(includingFractionalSeconds: true)
            .timeSeparator(.colon)
            .timeZone(separator: .omitted)
    }

    /// Attempts to extract only the last path component of the `file`
    var fileName: String {
        URL(fileURLWithPath: file).lastPathComponent
    }
}
