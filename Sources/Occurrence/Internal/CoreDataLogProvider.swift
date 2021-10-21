import Foundation
import Logging
#if canImport(CoreData)
import CoreData

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
class CoreDataLogProvider: LogProvider {
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        do {
            let directory = try FileManager.default.occurrenceDirectory()
            let url = directory.appendingPathComponent("LogProvider.sqlite")
            
            let description = NSPersistentStoreDescription()
            description.shouldInferMappingModelAutomatically = true
            description.shouldMigrateStoreAutomatically = true
            description.type = NSSQLiteStoreType
            description.url = url
            
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
            return container
        } catch {
            return nil
        }
    }()
    
    public func log(_ entry: Logger.Entry) {
        guard let context = persistentContainer?.newBackgroundContext() else {
            return
        }
        
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
        guard let context = persistentContainer?.newBackgroundContext() else {
            return []
        }
        
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
        
        guard let dictionary = fetch else {
            return []
        }
        
        return dictionary.compactMap { $0[#keyPath(ManagedEntry.subsystem)] }.map { Logger.Subsystem(stringLiteral: $0) }
    }
    
    public func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        guard let context = persistentContainer?.newBackgroundContext() else {
            return []
        }
        
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
        guard let context = persistentContainer?.newBackgroundContext() else {
            return
        }
        
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
