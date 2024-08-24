import Foundation
import Logging
#if canImport(CoreData)
@preconcurrency import CoreData

final class CoreDataLogStorage: LogStorage {
    
    let storeUrl: URL
    private let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init(url: URL? = nil) throws {
        storeUrl = try url ?? FileManager.default.defaultDatabaseUrl()
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.type = NSSQLiteStoreType
        description.url = storeUrl
        
        var loadError: Error?
        
        let managedObjectModel = LogModel.version_1_0_0.managedObjectModel()
        let container = NSPersistentContainer(name: "Occurrence", managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                loadError = error
            }
        }
        
        if let error = loadError {
            throw error
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer = container
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    deinit {
        let context = persistentContainer.viewContext
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
        }
        
        let coordinator = persistentContainer.persistentStoreCoordinator
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
                options: options
            )
            try coordinator.remove(store)
        } catch {
            print(error)
        }
    }
    
    public func log(_ entry: Logger.Entry) {
        backgroundContext.performAndWait {
            do {
                try ManagedEntry(context: backgroundContext, entry: entry)
                try backgroundContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    public func subsystems() -> [Logger.Subsystem] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedEntry.fetchRequest().entityName ?? "ManagedEntry")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [#keyPath(ManagedEntry.subsystem)]
        request.returnsDistinctResults = true
        
        var subsystems: Set<Logger.Subsystem> = [.occurrence]
        
        backgroundContext.performAndWait {
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
        }
        
        return Array(subsystems)
    }
    
    public func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        let request = ManagedEntry.fetchRequest()
        request.predicate = filter?.predicate
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ManagedEntry.date), ascending: ascending)
        ]
        if limit > 0 {
            request.fetchLimit = Int(limit)
        }
        
        var results: [Logger.Entry] = []
        
        backgroundContext.performAndWait {
            do {
                let entries = try backgroundContext.fetch(request)
                results = entries.map { $0.entry }
            } catch {
                print(error)
            }
        }
        
        return results
    }
    
    public func purge(matching filter: Logger.Filter?) {
        let request = ManagedEntry.fetchRequest()
        request.predicate = filter?.predicate
        
        backgroundContext.performAndWait {
            do {
                let entities = try backgroundContext.fetch(request)
                entities.forEach {
                    backgroundContext.delete($0)
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
