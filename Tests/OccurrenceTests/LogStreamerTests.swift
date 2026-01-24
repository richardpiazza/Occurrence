import Logging
@testable import Occurrence
import XCTest

final class LogStreamerTests: XCTestCase {

    func testStream() async throws {
        throw XCTSkip("Does not work in parallel execution.")
//        let streamer = OccurrenceLogStreamer()
//
//        let task = Task {
//            var entries: [Logger.Entry] = []
//            for await entry in streamer.stream {
//                entries.append(entry)
//            }
//            return entries
//        }
//
//        streamer.log(.init(subsystem: .occurrence, level: .trace, message: "a", source: "here"))
//        streamer.log(.init(subsystem: .occurrence, level: .debug, message: "b", source: "here"))
//        streamer.log(.init(subsystem: .occurrence, level: .info, message: "c", source: "here"))
//
//        try await Task.sleep(for: .milliseconds(250))
//        task.cancel()
//        let value = await task.value
//
//        XCTAssertEqual(value.count, 3)
    }
}
