import XCTest
import Logging
@testable import Occurrence

final class SQLiteLogProviderTests: LogStorageTestCase {
    
    var sqliteLogProvider: SQLiteLogStorage!
    override var logStorage: LogStorage! {
        get { sqliteLogProvider }
        set { }
    }
    
    override func setUpWithError() throws {
        sqliteLogProvider = try SQLiteLogStorage(url: Self.randomStoreUrl())
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        if let provider = logStorage {
            provider.purge()
        }
        
        let storeUrl = sqliteLogProvider.storeUrl
        try FileManager.default.removeItem(at: storeUrl)
        
        try super.tearDownWithError()
    }
}
