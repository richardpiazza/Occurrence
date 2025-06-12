import Foundation
import Logging
#if canImport(CoreData)
import CoreData

@objc(ManagedEntry)
class ManagedEntry: NSManagedObject {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedEntry> {
        NSFetchRequest<ManagedEntry>(entityName: "ManagedEntry")
    }

    @NSManaged var date: Date
    @NSManaged var subsystem: String
    @NSManaged var level: String
    @NSManaged var message: String
    @NSManaged var metadata: Data?
    @NSManaged var source: String
    @NSManaged var file: String
    @NSManaged var function: String
    @NSManaged var line: Int64
}

extension ManagedEntry {
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    @discardableResult
    convenience init(context: NSManagedObjectContext, entry: Logger.Entry) throws {
        self.init(context: context)
        date = entry.date
        subsystem = entry.subsystem.rawValue
        level = entry.level.rawValue
        message = entry.message.description
        if let metadata = entry.metadata {
            self.metadata = try Self.encoder.encode(metadata)
        }
        source = entry.source
        file = entry.file
        function = entry.function
        line = Int64(entry.line)
    }

    var entry: Logger.Entry {
        var meta: Logger.Metadata?
        if let metadata {
            meta = try? Self.decoder.decode(Logger.Metadata.self, from: metadata)
        }

        return Logger.Entry(
            date: date,
            subsystem: Logger.Subsystem(stringLiteral: subsystem),
            level: Logger.Level(rawValue: level) ?? .info,
            message: Logger.Message(stringLiteral: message),
            metadata: meta,
            source: source,
            file: file,
            function: function,
            line: UInt(line)
        )
    }
}
#endif
