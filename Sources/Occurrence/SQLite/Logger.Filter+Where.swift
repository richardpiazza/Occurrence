import Foundation
import Logging
import Statement
import StatementSQLite

extension Logger.Filter {
    var whereClause: [Segment<SQLiteStatement.WhereContext>] {
        switch self {
        case .subsystem(let subsystem):
            return [.column(SQLiteEntry.subsystem, op: .equal, value: subsystem.rawValue)]
        case .level(let level):
            return [.column(SQLiteEntry.levelRawValue, op: .equal, value: level.rawValue)]
        case .message(let message):
            if message.contains("%") {
                return [.column(SQLiteEntry.message, op: .like, value: message)]
            } else {
                return [.column(SQLiteEntry.message, op: .like, value: ["%", message, "%"].joined())]
            }
        case .source(let source):
            if source.contains("%") {
                return [.column(SQLiteEntry.source, op: .like, value: source)]
            } else {
                return [.column(SQLiteEntry.source, op: .like, value: ["%", source, "%"].joined())]
            }
        case .file(let file):
            if file.contains("%") {
                return [.column(SQLiteEntry.file, op: .like, value: file)]
            } else {
                return [.column(SQLiteEntry.file, op: .like, value: ["%", file, "%"].joined())]
            }
        case .function(let function):
            if function.contains("%") {
                return [.column(SQLiteEntry.function, op: .like, value: function)]
            } else {
                return [.column(SQLiteEntry.function, op: .like, value: ["%", function, "%"].joined())]
            }
        case .period(let start, let end):
            return [
                .AND(
                    .column(SQLiteEntry.date, op: .greaterThanEqualTo, value: start),
                    .column(SQLiteEntry.date, op: .lessThanEqualTo, value: end)
                )
            ]
        case .and(let filters):
            return [
                .AND(filters.flatMap { $0.whereClause })
            ]
        case .or(let filters):
            return [
                .OR(filters.flatMap { $0.whereClause })
            ]
        case .not(let filters):
            return [
                .AND(filters.flatMap { $0.inverseWhereClause })
            ]
        }
    }
    
    var inverseWhereClause: [Segment<SQLiteStatement.WhereContext>] {
        switch self {
        case .subsystem(let subsystem):
            return [.column(SQLiteEntry.subsystem, op: .notEqual, value: subsystem.rawValue)]
        case .level(let level):
            return [.column(SQLiteEntry.levelRawValue, op: .notEqual, value: level.rawValue)]
        case .message(let message):
            return [.column(SQLiteEntry.message, op: .notEqual, value: message)]
        case .source(let source):
            return [.column(SQLiteEntry.source, op: .notEqual, value: source)]
        case .file(let file):
            return [.column(SQLiteEntry.file, op: .notEqual, value: file)]
        case .function(let function):
            return [.column(SQLiteEntry.function, op: .notEqual, value: function)]
        case .period(let start, let end):
            return [
                .AND(
                    .column(SQLiteEntry.date, op: .lessThan, value: start),
                    .column(SQLiteEntry.date, op: .greaterThan, value: end)
                )
            ]
        case .and(let filters):
            return [
                .AND(filters.flatMap { $0.inverseWhereClause })
            ]
        case .or(let filters):
            return [
                .OR(filters.flatMap { $0.inverseWhereClause })
            ]
        case .not:
            // TODO: What happens here?
            return []
        }
    }
}
