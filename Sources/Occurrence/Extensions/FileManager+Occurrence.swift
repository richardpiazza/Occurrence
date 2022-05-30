import Foundation

extension FileManager {
    /// Locates (and creates) the **Occurrence** package directory.
    func occurrenceDirectory() throws -> URL {
        #if os(tvOS)
        let applicationSupport = try url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        #else
        let applicationSupport = try url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        #endif
        let directory = applicationSupport.appendingPathComponent("Occurrence", isDirectory: true)
        if !fileExists(atPath: directory.path) {
            try createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        return directory
    }
    
    func defaultDatabaseUrl() throws -> URL {
        let directory = try occurrenceDirectory()
        return directory.appendingPathComponent("LogProvider.sqlite")
    }
}
