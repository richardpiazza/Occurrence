import Logging
@testable import Occurrence
import XCTest

final class LogStreamerTests: XCTestCase {

    let streamer: LogStreamer = OccurrenceLogStreamer()

    func testStream() async {
        let stream = streamer.stream

        Task {
            try await Task.sleep(nanoseconds: 500_000)
            streamer.log(.init(subsystem: .occurrence, level: .trace, message: "a", source: "here"))
            streamer.log(.init(subsystem: .occurrence, level: .debug, message: "b", source: "here"))
            streamer.log(.init(subsystem: .occurrence, level: .info, message: "c", source: "here"))
            _ = streamer.stream // Force existing stream to finish
        }

        var entries: [Logger.Entry] = []
        for await entry in stream {
            entries.append(entry)
        }

        XCTAssertEqual(entries.count, 3)
    }
}
