import Foundation
import Logging
import SQLite
import Statement
import StatementSQLite

class SQLiteLogProvider: LogProvider {
    
    public static func defaultURL() throws -> URL {
        let directory = try FileManager.default.occurrenceDirectory()
        let url = directory.appendingPathComponent("LogProvider.sqlite")
        return url
    }
    
    private let db: Connection
    let storeUrl: URL
    
    init(url: URL? = nil) throws {
        storeUrl = try url ?? FileManager.default.defaultDatabaseUrl()
        db = try Connection(storeUrl.path)
        try db.prepare()
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
            try db.run(statement)
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
            for row in try db.run(sql) {
                if let name = row[0] as? String {
                    subsystems.insert(Logger.Subsystem(stringLiteral: name))
                }
            }
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
            for row in try db.run(sql) {
                let metadata: Data?
                if let blob = row[5] as? Blob {
                    metadata = Data(bytes: blob.bytes, count: blob.bytes.count)
                } else if let string = row[5] as? String {
                    metadata = string.data(using: .utf8)
                } else {
                    metadata = nil
                }
                
                let entry = SQLiteEntry(
                    id: Int(row[0] as! Int64),
                    date: Date(timeIntervalSince1970: row[1] as! Double),
                    subsystem: row[2] as! String,
                    levelRawValue: row[3] as! String,
                    message: row[4] as! String,
                    metadata: metadata,
                    source: row[6] as! String,
                    file: row[7] as! String,
                    function: row[8] as! String,
                    line: Int(row[9] as! Int64)
                )
                
                entries.append(Logger.Entry(entry))
            }
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
            try db.run(sql)
        } catch {
            print("SQLiteLogProvider \(#line): \(error)\n\(sql)")
        }
    }
}

extension Connection {
    func prepare() throws {
        let names = tableNames
        guard !names.contains(SQLiteEntry.identifier) else {
            return
        }
        
        let sql = SQLiteStatement(
            .CREATE(
                .SCHEMA(SQLiteEntry.instance, ifNotExists: true)
            )
        ).render()
        
        do {
            try run(sql)
        } catch {
            throw error
        }
    }
    
    private var tableNames: [String] {
        var names: [String] = []
        
        let sql = "SELECT name FROM sqlite_master WHERE type='table';"
        
        do {
            for row in try run(sql) {
                if let name = row[0] as? String {
                    names.append(name)
                }
            }
        } catch {
            print("SQLiteLogProvider \(#line): \(error)")
        }
        
        return names
    }
}
