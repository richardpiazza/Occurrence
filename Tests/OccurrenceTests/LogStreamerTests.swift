import XCTest
import Logging
@testable import Occurrence

final class LogStreamerTests: XCTestCase {
    
    let streamer: OccurrenceLogStreamer = OccurrenceLogStreamer()
    
    func testStream() async throws {
        let t1 = Task {
            var entries: [Logger.Entry] = []
            for await entry in await streamer.stream() {
                entries.append(entry)
            }
            return entries
        }
        
        Task {
            try await Task.sleep(nanoseconds: 500_000)
            streamer.log(.init(subsystem: .occurrence, level: .trace, message: "a", source: "here"))
            streamer.log(.init(subsystem: .occurrence, level: .debug, message: "b", source: "here"))
            streamer.log(.init(subsystem: .occurrence, level: .info, message: "c", source: "here"))
            streamer.terminate()
            try await Task.sleep(nanoseconds: 500_000)
        }
        
        let values = await t1.value
        XCTAssertEqual(values.count, 3)
    }
}
