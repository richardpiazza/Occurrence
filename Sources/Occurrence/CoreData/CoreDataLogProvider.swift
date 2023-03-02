import Foundation
import Logging
#if canImport(CoreData)
import CoreData

class CoreDataLogProvider: LogProvider {
    
    private var persistentContainer: NSPersistentContainer
    let storeUrl: URL
    
    init(url: URL? = nil) throws {
        storeUrl = try url ?? FileManager.default.defaultDatabaseUrl()
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.type = NSSQLiteStoreType
        description.url = storeUrl
        
        var loadError: Error?
        
        let container = NSPersistentContainer(name: "Occurrence", managedObjectModel: LogModel.default.managedObjectModel)
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
    }
    
    deinit {
        let coordinator = persistentContainer.persistentStoreCoordinator
        let stores = coordinator.persistentStores
        do {
            try stores.forEach { try coordinator.remove($0) }
        } catch {
        }
    }
    
    public func log(_ entry: Logger.Entry) {
        let context = persistentContainer.newBackgroundContext()
        
        context.performAndWait {
            do {
                try ManagedEntry(context: context, entry: entry)
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    public func subsystems() -> [Logger.Subsystem] {
        let context = persistentContainer.newBackgroundContext()
        
        let request: NSFetchRequest<NSFetchRequestResult> = ManagedEntry.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [#keyPath(ManagedEntry.subsystem)]
        request.returnsDistinctResults = true
        
        var fetch: [[String: String]]?
        
        context.performAndWait {
            do {
                fetch = try context.fetch(request) as? [[String : String]]
            } catch {
                print(error)
            }
        }
        
        var subsystems: Set<Logger.Subsystem> = [.occurrence]
        
        guard let dictionary = fetch else {
            return Array(subsystems)
        }
        
        dictionary
            .compactMap { $0[#keyPath(ManagedEntry.subsystem)] }
            .map { Logger.Subsystem(stringLiteral: $0) }
            .forEach {
                subsystems.insert($0)
            }
        
        return Array(subsystems)
    }
    
    public func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        let context = persistentContainer.newBackgroundContext()
        
        let request: NSFetchRequest<NSFetchRequestResult> = ManagedEntry.fetchRequest()
        request.predicate = filter?.predicate
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ManagedEntry.date), ascending: ascending)
        ]
        if limit > 0 {
            request.fetchLimit = Int(limit)
        }
        
        var fetch: [ManagedEntry] = []
        
        context.performAndWait {
            do {
                if let entities = try context.fetch(request) as? [ManagedEntry] {
                    fetch = entities
                }
            } catch {
                print(error)
            }
        }
        
        return fetch.map { $0.entry }
    }
    
    public func purge(matching filter: Logger.Filter?) {
        let context = persistentContainer.newBackgroundContext()
        
        let request: NSFetchRequest<NSFetchRequestResult> = ManagedEntry.fetchRequest()
        request.predicate = filter?.predicate
        
        context.performAndWait {
            do {
                let entities = try context.fetch(request) as? [ManagedEntry]
                entities?.forEach {
                    context.delete($0)
                }
                try context.save()
            } catch {
                print(error)
            }
        }
    }
}
#endif
