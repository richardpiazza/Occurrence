import Foundation
import Logging
#if canImport(CoreData)
import CoreData

extension Logger.Filter {
    var predicate: NSPredicate {
        switch self {
        case .subsystem(let subsystem):
            NSPredicate(format: "%K == %@", #keyPath(ManagedEntry.subsystem), subsystem.rawValue)
        case .level(let level):
            NSPredicate(format: "%K == %@", #keyPath(ManagedEntry.level), level.rawValue)
        case .message(let message):
            NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.message), message)
        case .source(let source):
            NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.source), source)
        case .file(let file):
            NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.file), file)
        case .function(let function):
            NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ManagedEntry.function), function)
        case .period(let start, let end):
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "%K >= %@", #keyPath(ManagedEntry.date), start as NSDate),
                NSPredicate(format: "%K <= %@", #keyPath(ManagedEntry.date), end as NSDate),
            ])
        case .and(let filters):
            NSCompoundPredicate(type: .and, subpredicates: filters.map(\.predicate))
        case .or(let filters):
            NSCompoundPredicate(type: .or, subpredicates: filters.map(\.predicate))
        case .not(let filters):
            NSCompoundPredicate(type: .not, subpredicates: filters.map(\.predicate))
        }
    }
}
#endif
