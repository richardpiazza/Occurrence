import Foundation
import Logging
import Mutex
#if canImport(CoreData)
@preconcurrency import CoreData

final class CoreDataLogProvider: LogProvider {

    let storeUrl: URL
    private let persistentContainer: Mutex<NSPersistentContainer>
    private let context: Mutex<NSManagedObjectContext>

    init(url: URL? = nil) throws {
        storeUrl = try url ?? FileManager.default.defaultDatabaseUrl()

        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.type = NSSQLiteStoreType
        description.url = storeUrl

        var loadError: (any Error)?

        let container = NSPersistentContainer(name: "Occurrence", managedObjectModel: LogModel.default.managedObjectModel)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                loadError = error
            }
        }

        if let error = loadError {
            throw error
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer = Mutex(container)

        let backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        context = Mutex(backgroundContext)
    }

    deinit {
        let container = persistentContainer.withLock { $0 }
        let context = container.viewContext
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
        }

        let coordinator = container.persistentStoreCoordinator
        let stores = coordinator.persistentStores
        do {
            for store in stores {
                try coordinator.remove(store)
            }

            // Checkpoint (merge WAL)
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: coordinator.name,
                at: storeUrl,
                options: options,
            )
            try coordinator.remove(store)
        } catch {
            print(error)
        }
    }

    func log(_ entry: Logger.Entry) {
        let backgroundContext = context.withLock { $0 }
        backgroundContext.performAndWait {
            do {
                try ManagedEntry(context: backgroundContext, entry: entry)
                try backgroundContext.save()
            } catch {
                print(error)
            }
        }
    }

    func subsystems() -> [Logger.Subsystem] {
        let request = NSFetchRequest<any NSFetchRequestResult>(entityName: ManagedEntry.fetchRequest().entityName ?? "ManagedEntry")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [#keyPath(ManagedEntry.subsystem)]
        request.returnsDistinctResults = true

        let backgroundContext = context.withLock { $0 }

        let subsystems = backgroundContext.performAndWait {
            var subsystems: Set<Logger.Subsystem> = [.occurrence]
            do {
                let results = try backgroundContext.fetch(request) as? [[String: String]]
                results?
                    .compactMap { $0[#keyPath(ManagedEntry.subsystem)] }
                    .map { Logger.Subsystem($0) }
                    .forEach {
                        subsystems.insert($0)
                    }
            } catch {
                print(error)
            }
            return subsystems
        }

        return Array(subsystems)
    }

    func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        let request = ManagedEntry.fetchRequest()
        request.predicate = filter?.predicate
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ManagedEntry.date), ascending: ascending),
        ]
        if limit > 0 {
            request.fetchLimit = Int(limit)
        }

        let backgroundContext = context.withLock { $0 }

        return backgroundContext.performAndWait {
            var results: [Logger.Entry] = []
            do {
                let entries = try backgroundContext.fetch(request)
                results = entries.map(\.entry)
            } catch {
                print(error)
            }
            return results
        }
    }

    func purge(matching filter: Logger.Filter?) {
        let request = ManagedEntry.fetchRequest()
        request.predicate = filter?.predicate

        let backgroundContext = context.withLock { $0 }

        backgroundContext.performAndWait {
            do {
                let entities = try backgroundContext.fetch(request)
                for entity in entities {
                    backgroundContext.delete(entity)
                }
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                print(error)
            }
        }
    }
}
#endif
