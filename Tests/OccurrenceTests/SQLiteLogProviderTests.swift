import XCTest
import Logging
@testable import Occurrence

final class SQLiteLogProviderTests: LogProviderTestCase {
    
    var sqliteLogProvider: SQLiteLogProvider!
    override var logProvider: LogProvider! {
        get { sqliteLogProvider }
        set { }
    }
    
    override func setUpWithError() throws {
        sqliteLogProvider = try SQLiteLogProvider(url: Self.randomStoreUrl())
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        if let provider = logProvider {
            provider.purge()
        }
        
        let storeUrl = sqliteLogProvider.storeUrl
        try FileManager.default.removeItem(at: storeUrl)
        
        try super.tearDownWithError()
    }
}
