import Foundation
import Logging
import Statement
import StatementSQLite

extension Logger.Filter {
    var whereClause: [Segment<SQLiteStatement.WhereContext>] {
        switch self {
        case .subsystem(let subsystem):
            [.column(SQLiteEntry.subsystem, op: .equal, value: subsystem.rawValue)]
        case .level(let level):
            [.column(SQLiteEntry.levelRawValue, op: .equal, value: level.rawValue)]
        case .message(let message):
            if message.contains("%") {
                [.column(SQLiteEntry.message, op: .like, value: message)]
            } else {
                [.column(SQLiteEntry.message, op: .like, value: ["%", message, "%"].joined())]
            }
        case .source(let source):
            if source.contains("%") {
                [.column(SQLiteEntry.source, op: .like, value: source)]
            } else {
                [.column(SQLiteEntry.source, op: .like, value: ["%", source, "%"].joined())]
            }
        case .file(let file):
            if file.contains("%") {
                [.column(SQLiteEntry.file, op: .like, value: file)]
            } else {
                [.column(SQLiteEntry.file, op: .like, value: ["%", file, "%"].joined())]
            }
        case .function(let function):
            if function.contains("%") {
                [.column(SQLiteEntry.function, op: .like, value: function)]
            } else {
                [.column(SQLiteEntry.function, op: .like, value: ["%", function, "%"].joined())]
            }
        case .period(let start, let end):
            [
                .AND(
                    .column(SQLiteEntry.date, op: .greaterThanEqualTo, value: start),
                    .column(SQLiteEntry.date, op: .lessThanEqualTo, value: end)
                ),
            ]
        case .and(let filters):
            [
                .AND(filters.flatMap(\.whereClause)),
            ]
        case .or(let filters):
            [
                .OR(filters.flatMap(\.whereClause)),
            ]
        case .not(let filters):
            [
                .AND(filters.flatMap(\.inverseWhereClause)),
            ]
        }
    }

    var inverseWhereClause: [Segment<SQLiteStatement.WhereContext>] {
        switch self {
        case .subsystem(let subsystem):
            [.column(SQLiteEntry.subsystem, op: .notEqual, value: subsystem.rawValue)]
        case .level(let level):
            [.column(SQLiteEntry.levelRawValue, op: .notEqual, value: level.rawValue)]
        case .message(let message):
            [.column(SQLiteEntry.message, op: .notEqual, value: message)]
        case .source(let source):
            [.column(SQLiteEntry.source, op: .notEqual, value: source)]
        case .file(let file):
            [.column(SQLiteEntry.file, op: .notEqual, value: file)]
        case .function(let function):
            [.column(SQLiteEntry.function, op: .notEqual, value: function)]
        case .period(let start, let end):
            [
                .AND(
                    .column(SQLiteEntry.date, op: .lessThan, value: start),
                    .column(SQLiteEntry.date, op: .greaterThan, value: end)
                ),
            ]
        case .and(let filters):
            [
                .AND(filters.flatMap(\.inverseWhereClause)),
            ]
        case .or(let filters):
            [
                .OR(filters.flatMap(\.inverseWhereClause)),
            ]
        case .not:
            // TODO: What happens here?
            []
        }
    }
}
