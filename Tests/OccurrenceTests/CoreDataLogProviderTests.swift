import XCTest
import Logging
@testable import Occurrence
#if canImport(CoreData)
import CoreData

final class CoreDataLogProviderTests: LogProviderTestCase {
    
    var coreDataLogProvider: CoreDataLogProvider!
    override var logProvider: LogProvider! {
        get { coreDataLogProvider }
        set { }
    }
    
    override func setUpWithError() throws {
        coreDataLogProvider = try CoreDataLogProvider(url: Self.randomStoreUrl())
        
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
