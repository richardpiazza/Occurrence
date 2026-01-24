import Logging
@testable import Occurrence
import Testing

struct LogStreamerTests {

    @Test func asyncStream() async throws {
        let streamer = OccurrenceLogStreamer()

        let task = Task {
            var entries: [Logger.Entry] = []
            for await entry in streamer.stream {
                entries.append(entry)
            }
            return entries
        }

        try await Task.sleep(for: .milliseconds(250))
        streamer.log(Logger.Entry(subsystem: .occurrence, level: .trace, message: "a", source: "here"))
        streamer.log(Logger.Entry(subsystem: .occurrence, level: .debug, message: "b", source: "here"))
        streamer.log(Logger.Entry(subsystem: .occurrence, level: .info, message: "c", source: "here"))
        try await Task.sleep(for: .milliseconds(250))
        task.cancel()

        let values = await task.value

        #expect(values.count == 3)
    }
}
