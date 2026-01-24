#if canImport(CoreData)
import CoreData
#endif
import Foundation
import Logging
@testable import Occurrence
import Testing

final class LogProviderTests {

    private static func randomStoreUrl() -> URL {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let path = "\(UUID().uuidString).sqlite"
        return URL(fileURLWithPath: path, relativeTo: directory)
    }

    private static var logProviders: [any LogProvider] {
        get throws {
            var providers: [any LogProvider] = []
            #if canImport(CoreData)
            try providers.append(CoreDataLogProvider(url: Self.randomStoreUrl()))
            #endif
            try providers.append(SQLiteLogProvider(url: Self.randomStoreUrl()))
            return providers
        }
    }

    private let subsystem1: Logger.Subsystem = "log.provider.1"
    private let subsystem2: Logger.Subsystem = "log.provider.2"
    private let january1st_1530: Date
    private let january1st_1630: Date
    private let january2nd_0808: Date
    private let january2nd_0809: Date

    init() throws {
        let gregorian = Calendar(identifier: .gregorian)
        let gmt = TimeZone(secondsFromGMT: 0)
        var components = DateComponents(
            calendar: gregorian,
            timeZone: gmt,
            year: 2022,
            month: 1,
            day: 1,
            hour: 15,
            minute: 30,
            second: 0,
        )

        january1st_1530 = try #require(gregorian.date(from: components))

        components.hour = 16
        january1st_1630 = try #require(gregorian.date(from: components))

        components.day = 2
        components.hour = 8
        components.minute = 8
        january2nd_0808 = try #require(gregorian.date(from: components))

        components.minute = 9
        january2nd_0809 = try #require(gregorian.date(from: components))
    }

    deinit {
        do {
            for provider in try Self.logProviders {
                provider.purge()

                switch provider {
                #if canImport(CoreData)
                case let logProvider as CoreDataLogProvider:
                    let url = logProvider.storeUrl
                    let shm = url.deletingPathExtension().appendingPathExtension("sqlite-shm")
                    let wal = url.deletingPathExtension().appendingPathExtension("sqlite-wal")
                    try FileManager.default.removeItem(at: url)
                    try FileManager.default.removeItem(at: shm)
                    try FileManager.default.removeItem(at: wal)
                #endif
                case let logProvider as SQLiteLogProvider:
                    let url = logProvider.storeUrl
                    try FileManager.default.removeItem(at: url)
                default:
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    @Test(arguments: try Self.logProviders)
    func subsystems(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(date: january1st_1630, subsystem: subsystem2, level: .debug, message: "two", metadata: nil, source: ""))

        let subsystems = logProvider
            .subsystems()
            .map(\.rawValue)
            .sorted()

        #expect(subsystems == [
            "com.richardpiazza.occurrence",
            "log.provider.1",
            "log.provider.2",
        ])
    }

    @Test(arguments: try Self.logProviders)
    func subsystemFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(date: january1st_1630, subsystem: subsystem2, level: .debug, message: "two", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0809, subsystem: subsystem2, level: .debug, message: "four", metadata: nil, source: ""))

        let entries = logProvider
            .entries(.subsystem(subsystem1), ascending: true)
            .map(\.message)

        #expect(entries.count == 2)
        #expect(entries == ["one", "three"])
    }

    @Test(arguments: try Self.logProviders)
    func levelFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "one", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .debug, message: "two", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .info, message: "three", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .notice, message: "four", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .warning, message: "five", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .error, message: "six", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .critical, message: "seven", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .critical, message: "eight", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .error, message: "nine", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "ten", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .notice, message: "eleven", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .info, message: "twelve", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "thirteen", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .trace, message: "fourteen", metadata: nil, source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(.level(.trace), ascending: true)
            .map(\.message)
        #expect(entries == ["one", "fourteen"])

        entries = logProvider
            .entries(.level(.debug), ascending: false)
            .map(\.message)
        #expect(entries == ["thirteen", "two"])

        entries = logProvider
            .entries(.level(.info), ascending: true)
            .map(\.message)
        #expect(entries == ["three", "twelve"])

        entries = logProvider
            .entries(.level(.notice), ascending: false)
            .map(\.message)
        #expect(entries == ["eleven", "four"])

        entries = logProvider
            .entries(.level(.warning), ascending: true)
            .map(\.message)
        #expect(entries == ["five", "ten"])

        entries = logProvider
            .entries(.level(.error), ascending: false)
            .map(\.message)
        #expect(entries == ["nine", "six"])

        entries = logProvider
            .entries(.level(.critical), ascending: true)
            .map(\.message)
        #expect(entries == ["seven", "eight"])
    }

    @Test(arguments: try Self.logProviders)
    func messageFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .debug, message: "for", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .debug, message: "forward", metadata: nil, source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .debug, message: "warden", metadata: nil, source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(.message("for"), ascending: true)
            .map(\.message)
        #expect(entries == ["for", "forward"])

        entries = logProvider
            .entries(.message("ward"), ascending: true)
            .map(\.message)
        #expect(entries == ["forward", "warden"])
    }

    @Test(arguments: try Self.logProviders)
    func sourceFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "one", source: "Class1"))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "two", source: "Class2"))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "three", source: "Class3"))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "four", source: "Class3"))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "five", source: "Class2"))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "six", source: "Class1"))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(.source("Class1"))
            .map(\.message)
        #expect(entries == ["six", "one"])

        entries = logProvider
            .entries(.source("class"))
            .map(\.message)
        #expect(entries.count == 6)
    }

    @Test(arguments: try Self.logProviders)
    func fileFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "one", source: "", file: "File1.swift"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "two", source: "", file: "File2.swift"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "three", source: "", file: "File3.swift"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "four", source: "", file: "File3.swift"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "five", source: "", file: "File2.swift"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "six", source: "", file: "File1.swift"))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(.file("File2.swift"))
            .map(\.message)
        #expect(entries == ["five", "two"])

        entries = logProvider
            .entries(.file("file"))
            .map(\.message)
        #expect(entries.count == 6)
    }

    @Test(arguments: try Self.logProviders)
    func functionFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "one", source: "", function: "doWork()"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "two", source: "", function: "presentData()"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "three", source: "", function: "asyncTask(_:)"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "four", source: "", function: "asyncTask(_:)"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "five", source: "", function: "presentData()"))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "six", source: "", function: "doWork()"))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(.function("async"))
            .map(\.message)
        #expect(entries == ["four", "three"])

        entries = logProvider
            .entries(.function("(_:)"))
            .map(\.message)
        #expect(entries.count == 2)
    }

    @Test(arguments: try Self.logProviders)
    func periodFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logProvider.log(Logger.Entry(date: january1st_1630, subsystem: subsystem2, level: .debug, message: "two", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0809, subsystem: subsystem2, level: .debug, message: "four", source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(.period(start: .distantPast, end: january2nd_0808))
            .map(\.message)
        #expect(entries == ["three", "two", "one"])

        entries = logProvider
            .entries(.period(start: january1st_1630, end: january2nd_0808))
            .map(\.message)
        #expect(entries == ["three", "two"])
    }

    @Test(arguments: try Self.logProviders)
    func andFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logProvider.log(Logger.Entry(date: january1st_1630, subsystem: subsystem2, level: .info, message: "two", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0809, subsystem: subsystem2, level: .warning, message: "four", source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(
                .and([
                    .period(start: january2nd_0808, end: january2nd_0809),
                    .level(.debug),
                ]),
            )
            .map(\.message)
        #expect(entries == ["three"])

        entries = logProvider
            .entries(
                .and([
                    .subsystem(subsystem2),
                    .level(.warning),
                ]),
            )
            .map(\.message)
        #expect(entries == ["four"])
    }

    @Test(arguments: try Self.logProviders)
    func orFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logProvider.log(Logger.Entry(date: january1st_1630, subsystem: subsystem2, level: .info, message: "two", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0809, subsystem: subsystem2, level: .warning, message: "four", source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(
                .or([
                    .level(.debug),
                    .level(.info),
                ]),
            )
            .map(\.message)
        #expect(entries == ["three", "two", "one"])
    }

    @Test(arguments: try Self.logProviders)
    func notFilter(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logProvider.log(Logger.Entry(date: january1st_1630, subsystem: subsystem2, level: .info, message: "two", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logProvider.log(Logger.Entry(date: january2nd_0809, subsystem: subsystem2, level: .warning, message: "four", source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(
                .not([
                    .subsystem(subsystem1),
                ]),
            )
            .map(\.message)
        #expect(entries == ["four", "two"])
    }

    @Test(arguments: try Self.logProviders)
    func ascendingLimit(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "one", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .debug, message: "two", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .info, message: "three", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .notice, message: "four", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .warning, message: "five", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .error, message: "six", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .critical, message: "seven", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .critical, message: "eight", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .error, message: "nine", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "ten", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .notice, message: "eleven", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .info, message: "twelve", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "thirteen", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .trace, message: "fourteen", source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(ascending: true, limit: 4)
            .map(\.message)
        #expect(entries == ["one", "two", "three", "four"])
    }

    @Test(arguments: try Self.logProviders)
    func descendingLimit(logProvider: any LogProvider) throws {
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .trace, message: "one", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .debug, message: "two", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .info, message: "three", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .notice, message: "four", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .warning, message: "five", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .error, message: "six", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem1, level: .critical, message: "seven", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .critical, message: "eight", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .error, message: "nine", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .warning, message: "ten", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .notice, message: "eleven", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .info, message: "twelve", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .debug, message: "thirteen", source: ""))
        logProvider.log(Logger.Entry(subsystem: subsystem2, level: .trace, message: "fourteen", source: ""))

        var entries: [Logger.Message]

        entries = logProvider
            .entries(ascending: false, limit: 2)
            .map(\.message)
        #expect(entries == ["fourteen", "thirteen"])
    }
}
