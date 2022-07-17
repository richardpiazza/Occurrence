import Foundation
import Logging
import PerfectSQLite
import Statement
import StatementSQLite

class SQLiteLogProvider: LogProvider {
    
    public static func defaultURL() throws -> URL {
        let directory = try FileManager.default.occurrenceDirectory()
        let url = directory.appendingPathComponent("LogProvider.sqlite")
        return url
    }
    
    private let db: SQLite
    let storeUrl: URL
    
    init(url: URL? = nil) throws {
        storeUrl = try url ?? FileManager.default.defaultDatabaseUrl()
        db = try SQLite(storeUrl.path)
        try db.prepare()
    }
    
    deinit {
        db.close()
    }
    
    public func log(_ entry: Logger.Entry) {
        let sqlEntry = SQLiteEntry(entry)
        
        let statement = SQLiteStatement(
            .INSERT_INTO(SQLiteEntry.self,
                 .column(SQLiteEntry.date),
                 .column(SQLiteEntry.subsystem),
                 .column(SQLiteEntry.levelRawValue),
                 .column(SQLiteEntry.message),
                 .column(SQLiteEntry.metadata),
                 .column(SQLiteEntry.source),
                 .column(SQLiteEntry.file),
                 .column(SQLiteEntry.function),
                 .column(SQLiteEntry.line)
            ),
            .VALUES(
                .value(sqlEntry.date),
                .value(sqlEntry.subsystem),
                .value(sqlEntry.levelRawValue),
                .value(sqlEntry.message),
                .value(sqlEntry.metadata),
                .value(sqlEntry.source),
                .value(sqlEntry.file),
                .value(sqlEntry.function),
                .value(sqlEntry.line)
            )
        ).render()
        
        do {
            try db.doWithTransaction {
                try db.execute(statement: statement)
            }
        } catch {
            print("SQLiteLogProvider \(#line): \(error)\n\(statement)")
        }
    }
    
    public func subsystems() -> [Logger.Subsystem] {
        var subsystems: Set<Logger.Subsystem> = [.occurrence]
        
        let statement = SQLiteStatement(
            .SELECT_DISTINCT(
                .column(SQLiteEntry.subsystem)
            ),
            .FROM_TABLE(SQLiteEntry.self)
        )
        
        let sql = statement.render()
        
        do {
            try db.forEachRow(statement: sql, handleRow: { stmt, index in
                let name = stmt.columnText(position: 0)
                subsystems.insert(Logger.Subsystem(stringLiteral: name))
            })
        } catch {
            print("SQLiteLogProvider \(#line): \(error)\n\(sql)")
        }
        
        return subsystems.sorted()
    }
    
    public func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        var entries: [Logger.Entry] = []
        
        let statement: SQLiteStatement
        switch (filter, limit) {
        case (.some(let loggerFilter), let x) where x > 0:
            statement = SQLiteStatement(
                .SELECT(
                    .column(SQLiteEntry.id),
                    .column(SQLiteEntry.date),
                    .column(SQLiteEntry.subsystem),
                    .column(SQLiteEntry.levelRawValue),
                    .column(SQLiteEntry.message),
                    .column(SQLiteEntry.metadata),
                    .column(SQLiteEntry.source),
                    .column(SQLiteEntry.file),
                    .column(SQLiteEntry.function),
                    .column(SQLiteEntry.line)
                ),
                .FROM_TABLE(SQLiteEntry.self),
                .WHERE(loggerFilter.whereClause),
                .ORDER_BY(
                    .column(SQLiteEntry.date, op: ascending ? .asc : .desc)
                ),
                .LIMIT(Int(x))
            )
        case (.some(let loggerFilter), let x) where x == 0:
            statement = SQLiteStatement(
                .SELECT(
                    .column(SQLiteEntry.id),
                    .column(SQLiteEntry.date),
                    .column(SQLiteEntry.subsystem),
                    .column(SQLiteEntry.levelRawValue),
                    .column(SQLiteEntry.message),
                    .column(SQLiteEntry.metadata),
                    .column(SQLiteEntry.source),
                    .column(SQLiteEntry.file),
                    .column(SQLiteEntry.function),
                    .column(SQLiteEntry.line)
                ),
                .FROM_TABLE(SQLiteEntry.self),
                .WHERE(loggerFilter.whereClause),
                .ORDER_BY(
                    .column(SQLiteEntry.date, op: ascending ? .asc : .desc)
                )
            )
        case (.none, let x) where x > 0:
            statement = SQLiteStatement(
                .SELECT(
                    .column(SQLiteEntry.id),
                    .column(SQLiteEntry.date),
                    .column(SQLiteEntry.subsystem),
                    .column(SQLiteEntry.levelRawValue),
                    .column(SQLiteEntry.message),
                    .column(SQLiteEntry.metadata),
                    .column(SQLiteEntry.source),
                    .column(SQLiteEntry.file),
                    .column(SQLiteEntry.function),
                    .column(SQLiteEntry.line)
                ),
                .FROM_TABLE(SQLiteEntry.self),
                .ORDER_BY(
                    .column(SQLiteEntry.date, op: ascending ? .asc : .desc)
                ),
                .LIMIT(Int(x))
            )
        default:
            statement = SQLiteStatement(
                .SELECT(
                    .column(SQLiteEntry.id),
                    .column(SQLiteEntry.date),
                    .column(SQLiteEntry.subsystem),
                    .column(SQLiteEntry.levelRawValue),
                    .column(SQLiteEntry.message),
                    .column(SQLiteEntry.metadata),
                    .column(SQLiteEntry.source),
                    .column(SQLiteEntry.file),
                    .column(SQLiteEntry.function),
                    .column(SQLiteEntry.line)
                ),
                .FROM_TABLE(SQLiteEntry.self),
                .ORDER_BY(
                    .column(SQLiteEntry.date, op: ascending ? .asc : .desc)
                )
            )
        }
        
        let sql = statement.render()
        print(sql)
        
        do {
            try db.forEachRow(statement: sql, handleRow: { stmt, index in
                let metadata: Data?
                if stmt.isNull(position: 5) {
                    metadata = nil
                } else {
                    let ints: [UInt8] = stmt.columnIntBlob(position: 5)
                    metadata = Data(bytes: ints, count: ints.count)
                }
                
                let entry = SQLiteEntry(
                    id: stmt.columnInt(position: 0),
                    date: Date(timeIntervalSince1970: stmt.columnDouble(position: 1)),
                    subsystem: stmt.columnText(position: 2),
                    levelRawValue: stmt.columnText(position: 3),
                    message: stmt.columnText(position: 4),
                    metadata: metadata,
                    source: stmt.columnText(position: 6),
                    file: stmt.columnText(position: 7),
                    function: stmt.columnText(position: 8),
                    line: stmt.columnInt(position: 9)
                )
                
                entries.append(Logger.Entry(entry))
            })
        } catch {
            print("SQLiteLogProvider \(#line): \(error)")
        }
        
        return entries
    }
    
    public func purge(matching filter: Logger.Filter?) {
        let statement: SQLiteStatement
        
        if let filter = filter {
            statement = SQLiteStatement(
                .DELETE_FROM(SQLiteEntry.self),
                .WHERE(
                    filter.whereClause
                )
            )
        } else {
            statement = SQLiteStatement(
                .DELETE_FROM(SQLiteEntry.self)
            )
        }
        
        let sql = statement.render()
        
        do {
            try db.doWithTransaction {
                try db.execute(statement: sql)
            }
        } catch {
            print("SQLiteLogProvider \(#line): \(error)\n\(sql)")
        }
    }
}

extension SQLite {
    func prepare() throws {
        let names = tableNames
        guard !names.contains(SQLiteEntry.identifier) else {
            return
        }
        
        try doWithTransaction {
            try execute(
                statement: SQLiteStatement(
                    .CREATE(
                        .SCHEMA(SQLiteEntry.instance, ifNotExists: true)
                    )
                ).render()
            )
        }
    }
    
    private var tableNames: [String] {
        var names: [String] = []
        
        let sql = "SELECT name FROM sqlite_master WHERE type='table';"
        
        do {
            try forEachRow(statement: sql, handleRow: { (statement, index) in
                names.append(statement.columnText(position: 0))
            })
        } catch {
            print("SQLiteLogProvider \(#line): \(error)")
        }
        
        return names
    }
}
