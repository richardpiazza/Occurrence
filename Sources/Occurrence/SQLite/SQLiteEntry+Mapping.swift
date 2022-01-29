import Foundation
import Logging

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

extension SQLiteEntry {
    init(_ entry: Logger.Entry) {
        date = entry.date
        subsystem = entry.subsystem.rawValue
        level = entry.level
        message = entry.message.description
        if let value = entry.metadata {
            metadata = try? encoder.encode(value)
        }
        source = entry.source
        file = entry.file
        function = entry.function
        line = Int(entry.line)
    }
}

extension Logger.Entry {
    init(_ entry: SQLiteEntry) {
        date = entry.date
        subsystem = Logger.Subsystem(stringLiteral: entry.subsystem)
        level = entry.level
        message = Logger.Message(stringLiteral: entry.message)
        if let value = entry.metadata {
            metadata = try? decoder.decode(Logger.Metadata.self, from: value)
        } else {
            metadata = nil
        }
        source = entry.source
        file = entry.file
        function = entry.function
        line = UInt(entry.line)
    }
}
