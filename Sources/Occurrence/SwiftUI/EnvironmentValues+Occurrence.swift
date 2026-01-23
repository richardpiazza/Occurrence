#if canImport(SwiftUI)
import SwiftUI

public extension EnvironmentValues {
    var logStreamer: any LogStreamer {
        get { self[LogStreamerEnvironmentKey.self] }
        set { self[LogStreamerEnvironmentKey.self] = newValue }
    }

    var logProvider: any LogProvider {
        get { self[LogProviderEnvironmentKey.self] }
        set { self[LogProviderEnvironmentKey.self] = newValue }
    }
}

struct LogStreamerEnvironmentKey: EnvironmentKey {
    static let defaultValue: any LogStreamer = Occurrence.logStreamer
}

struct LogProviderEnvironmentKey: EnvironmentKey {
    static let defaultValue: any LogProvider = Occurrence.logProvider
}
#endif
