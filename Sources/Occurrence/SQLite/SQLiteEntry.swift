import Foundation
import Logging
import Statement

struct SQLiteEntry: Entity, Identifiable {

    static let identifier: String = "entry"

    @Field("id", unique: true, primaryKey: true, autoIncrement: true)
    var id: Int = 0
    @Field("date")
    var date: Date = Date()
    @Field("subsystem")
    var subsystem: String = ""
    @Field("level_raw_value")
    var levelRawValue: String = ""
    @Field("message")
    var message: String = ""
    @Field("metadata")
    var metadata: Data? = nil
    @Field("source")
    var source: String = ""
    @Field("file")
    var file: String = ""
    @Field("function")
    var function: String = ""
    @Field("line")
    var line: Int = 0

    var level: Logger.Level {
        get { Logger.Level(rawValue: levelRawValue) ?? .debug }
        set { levelRawValue = newValue.rawValue }
    }
}

extension SQLiteEntry {
    static let instance: SQLiteEntry = SQLiteEntry()
    static var id: any Attribute { instance["id"]! }
    static var date: any Attribute { instance["date"]! }
    static var subsystem: any Attribute { instance["subsystem"]! }
    static var levelRawValue: any Attribute { instance["level_raw_value"]! }
    static var message: any Attribute { instance["message"]! }
    static var metadata: any Attribute { instance["metadata"]! }
    static var source: any Attribute { instance["source"]! }
    static var file: any Attribute { instance["file"]! }
    static var function: any Attribute { instance["function"]! }
    static var line: any Attribute { instance["line"]! }
}
