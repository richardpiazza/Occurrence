import Foundation

extension FileManager {
    /// Locates (and creates) the **Occurrence** package directory.
    func occurrenceDirectory() throws -> URL {
        let applicationSupport = try url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = applicationSupport.appendingPathComponent("Occurrence", isDirectory: true)
        if !fileExists(atPath: directory.path) {
            try createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        return directory
    }
}
