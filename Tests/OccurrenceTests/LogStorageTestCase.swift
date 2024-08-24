import XCTest
import Logging
@testable import Occurrence

class LogStorageTestCase: XCTestCase {
    
    enum Error: Swift.Error {
        case nilLogProvider
    }
    
    static func randomStoreUrl() -> URL {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let path = "\(UUID().uuidString).sqlite"
        return URL(fileURLWithPath: path, relativeTo: directory)
    }
    
    var logStorage: LogStorage!
    
    let subsystem1: Logger.Subsystem = "log.provider.1"
    let subsystem2: Logger.Subsystem = "log.provider.2"
    
    let gregorian = Calendar(identifier: .gregorian)
    let gmt = TimeZone(secondsFromGMT: 0)
    
    var january1st_1530: Date!
    var january1st_1630: Date!
    var january2nd_0808: Date!
    var january2nd_0809: Date!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        var components = DateComponents(
            calendar: gregorian,
            timeZone: gmt,
            year: 2022,
            month: 1,
            day: 1,
            hour: 15,
            minute: 30,
            second: 0
        )
        
        january1st_1530 = try XCTUnwrap(gregorian.date(from: components))
        
        components.hour = 16
        january1st_1630 = try XCTUnwrap(gregorian.date(from: components))
        
        components.day = 2
        components.hour = 8
        components.minute = 8
        january2nd_0808 = try XCTUnwrap(gregorian.date(from: components))
        
        components.minute = 9
        january2nd_0809 = try XCTUnwrap(gregorian.date(from: components))
    }
    
    func testSubsystems() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", metadata: nil, source: ""))
        logStorage.log(.init(date: january1st_1630, subsystem: subsystem2, level: .debug, message: "two", metadata: nil, source: ""))
        
        let subsystems = logStorage.subsystems()
        XCTAssertEqual(subsystems.map(\.rawValue).sorted(), ["com.richardpiazza.occurrence", "log.provider.1", "log.provider.2"])
    }
    
    func testSubsystemFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", metadata: nil, source: ""))
        logStorage.log(.init(date: january1st_1630, subsystem: subsystem2, level: .debug, message: "two", metadata: nil, source: ""))
        logStorage.log(.init(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", metadata: nil, source: ""))
        logStorage.log(.init(date: january2nd_0809, subsystem: subsystem2, level: .debug, message: "four", metadata: nil, source: ""))
        
        let entries = logStorage.entries(.subsystem(subsystem1), ascending: true)
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.map(\.message), ["one", "three"])
    }
    
    func testLevelFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "one", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .debug, message: "two", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .info, message: "three", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .notice, message: "four", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .warning, message: "five", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .error, message: "six", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .critical, message: "seven", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .critical, message: "eight", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .error, message: "nine", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "ten", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .notice, message: "eleven", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .info, message: "twelve", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "thirteen", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .trace, message: "fourteen", metadata: nil, source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.level(.trace), ascending: true)
        XCTAssertEqual(entries.map(\.message), ["one", "fourteen"])
        
        entries = logStorage.entries(.level(.debug), ascending: false)
        XCTAssertEqual(entries.map(\.message), ["thirteen", "two"])
        
        entries = logStorage.entries(.level(.info), ascending: true)
        XCTAssertEqual(entries.map(\.message), ["three", "twelve"])
        
        entries = logStorage.entries(.level(.notice), ascending: false)
        XCTAssertEqual(entries.map(\.message), ["eleven", "four"])
        
        entries = logStorage.entries(.level(.warning), ascending: true)
        XCTAssertEqual(entries.map(\.message), ["five", "ten"])
        
        entries = logStorage.entries(.level(.error), ascending: false)
        XCTAssertEqual(entries.map(\.message), ["nine", "six"])
        
        entries = logStorage.entries(.level(.critical), ascending: true)
        XCTAssertEqual(entries.map(\.message), ["seven", "eight"])
    }
    
    func testMessageFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem1, level: .debug, message: "for", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .debug, message: "forward", metadata: nil, source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .debug, message: "warden", metadata: nil, source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.message("for"), ascending: true)
        XCTAssertEqual(entries.map(\.message), ["for", "forward"])
        
        entries = logStorage.entries(.message("ward"), ascending: true)
        XCTAssertEqual(entries.map(\.message), ["forward", "warden"])
    }
    
    func testSourceFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "one", source: "Class1"))
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "two", source: "Class2"))
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "three", source: "Class3"))
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "four", source: "Class3"))
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "five", source: "Class2"))
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "six", source: "Class1"))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.source("Class1"))
        XCTAssertEqual(entries.map(\.message), ["six", "one"])
        
        entries = logStorage.entries(.source("class"))
        XCTAssertEqual(entries.count, 6)
    }
    
    func testFileFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "one", source: "", file: "File1.swift"))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "two", source: "", file: "File2.swift"))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "three", source: "", file: "File3.swift"))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "four", source: "", file: "File3.swift"))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "five", source: "", file: "File2.swift"))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "six", source: "", file: "File1.swift"))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.file("File2.swift"))
        XCTAssertEqual(entries.map(\.message), ["five", "two"])
        
        entries = logStorage.entries(.file("file"))
        XCTAssertEqual(entries.count, 6)
    }
    
    func testFunctionFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "one", source: "", function: "doWork()"))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "two", source: "", function: "presentData()"))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "three", source: "", function: "asyncTask(_:)"))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "four", source: "", function: "asyncTask(_:)"))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "five", source: "", function: "presentData()"))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "six", source: "", function: "doWork()"))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.function("async"))
        XCTAssertEqual(entries.map(\.message), ["four", "three"])
        
        entries = logStorage.entries(.function("(_:)"))
        XCTAssertEqual(entries.count, 2)
    }
    
    func testPeriodFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logStorage.log(.init(date: january1st_1630, subsystem: subsystem2, level: .debug, message: "two", source: ""))
        logStorage.log(.init(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logStorage.log(.init(date: january2nd_0809, subsystem: subsystem2, level: .debug, message: "four", source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.period(start: .distantPast, end: january2nd_0808))
        XCTAssertEqual(entries.map(\.message), ["three", "two", "one"])
        
        entries = logStorage.entries(.period(start: january1st_1630, end: january2nd_0808))
        XCTAssertEqual(entries.map(\.message), ["three", "two"])
    }
    
    func testAndFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logStorage.log(.init(date: january1st_1630, subsystem: subsystem2, level: .info, message: "two", source: ""))
        logStorage.log(.init(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logStorage.log(.init(date: january2nd_0809, subsystem: subsystem2, level: .warning, message: "four", source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.and([
            .period(start: january2nd_0808, end: january2nd_0809),
            .level(.debug)
        ]))
        XCTAssertEqual(entries.map(\.message), ["three"])
        
        entries = logStorage.entries(.and([
            .subsystem(subsystem2),
            .level(.warning)
        ]))
        XCTAssertEqual(entries.map(\.message), ["four"])
    }
    
    func testOrFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logStorage.log(.init(date: january1st_1630, subsystem: subsystem2, level: .info, message: "two", source: ""))
        logStorage.log(.init(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logStorage.log(.init(date: january2nd_0809, subsystem: subsystem2, level: .warning, message: "four", source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.or([
            .level(.debug),
            .level(.info)
        ]))
        XCTAssertEqual(entries.map(\.message), ["three", "two", "one"])
    }
    
    func testNotFilter() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(date: january1st_1530, subsystem: subsystem1, level: .debug, message: "one", source: ""))
        logStorage.log(.init(date: january1st_1630, subsystem: subsystem2, level: .info, message: "two", source: ""))
        logStorage.log(.init(date: january2nd_0808, subsystem: subsystem1, level: .debug, message: "three", source: ""))
        logStorage.log(.init(date: january2nd_0809, subsystem: subsystem2, level: .warning, message: "four", source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(.not([
            .subsystem(subsystem1)
        ]))
        XCTAssertEqual(entries.map(\.message), ["four", "two"])
    }
    
    func testAscendingLimit() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "one", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .debug, message: "two", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .info, message: "three", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .notice, message: "four", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .warning, message: "five", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .error, message: "six", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .critical, message: "seven", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .critical, message: "eight", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .error, message: "nine", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "ten", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .notice, message: "eleven", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .info, message: "twelve", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "thirteen", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .trace, message: "fourteen", source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(ascending: true, limit: 4)
        XCTAssertEqual(entries.map(\.message), ["one", "two", "three", "four"])
    }
    
    func testDescendingLimit() throws {
        try XCTSkipIf(logStorage == nil)
        
        logStorage.log(.init(subsystem: subsystem1, level: .trace, message: "one", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .debug, message: "two", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .info, message: "three", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .notice, message: "four", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .warning, message: "five", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .error, message: "six", source: ""))
        logStorage.log(.init(subsystem: subsystem1, level: .critical, message: "seven", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .critical, message: "eight", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .error, message: "nine", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .warning, message: "ten", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .notice, message: "eleven", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .info, message: "twelve", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .debug, message: "thirteen", source: ""))
        logStorage.log(.init(subsystem: subsystem2, level: .trace, message: "fourteen", source: ""))
        
        var entries: [Logger.Entry]
        
        entries = logStorage.entries(ascending: false, limit: 2)
        XCTAssertEqual(entries.map(\.message), ["fourteen", "thirteen"])
    }
}
