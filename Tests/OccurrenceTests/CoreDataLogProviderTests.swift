import XCTest
import Logging
@testable import Occurrence
#if canImport(CoreData)
import CoreData

final class CoreDataLogProviderTests: LogStorageTestCase {
    
    var coreDataLogProvider: CoreDataLogStorage!
    override var logStorage: LogStorage! {
        get { coreDataLogProvider }
        set { }
    }
    
    override func setUpWithError() throws {
        coreDataLogProvider = try CoreDataLogStorage(url: Self.randomStoreUrl())
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        coreDataLogProvider.purge()
        
        let storeUrl = coreDataLogProvider.storeUrl
        let shm = storeUrl.deletingPathExtension().appendingPathExtension("sqlite-shm")
        let wal = storeUrl.deletingPathExtension().appendingPathExtension("sqlite-wal")
        
        try FileManager.default.removeItem(at: storeUrl)
        try FileManager.default.removeItem(at: shm)
        try FileManager.default.removeItem(at: wal)
        
        try super.tearDownWithError()
    }
}
#endif
