import Foundation
import Logging
#if canImport(CoreData)
import CoreData

extension Logger.Filter {
    var predicate: NSPredicate {
        switch self {
        case .subsystem(let subsystem):
            return NSPredicate(format: "%K == %@", #keyPath(ManagedEntry.subsystem), subsystem.rawValue)
        case .level(let level):
            return NSPredicate(format: "%K == %@", #keyPath(ManagedEntry.level), level.rawValue)
        case .message(let message):
            return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.message), message)
        case .source(let source):
            return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.source), source)
        case .file(let file):
            return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.file), file)
        case .function(let function):
            return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.function), function)
        case .period(let start, let end):
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "%K >= %@", #keyPath(ManagedEntry.date), start as NSDate),
                NSPredicate(format: "%K <= %@", #keyPath(ManagedEntry.date), end as NSDate)
            ])
        case .and(let filters):
            return NSCompoundPredicate(type: .and, subpredicates: filters.map { $0.predicate })
        case .or(let filters):
            return NSCompoundPredicate(type: .or, subpredicates: filters.map { $0.predicate })
        case .not(let filters):
            return NSCompoundPredicate(type: .not, subpredicates: filters.map { $0.predicate })
        }
    }
}
#endif
