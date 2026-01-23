import Foundation
import Logging

struct PreviewLogProvider: LogProvider {

    private let entries: [Logger.Entry] = [
        .one,
        .three,
        .two,
        .four,
    ]

    func log(_ entry: Logger.Entry) {}

    func subsystems() -> [Logger.Subsystem] {
        [.sub1, .sub2]
    }

    func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        if let filter {
            entries.filter { $0.matchesFilter(filter) }
        } else {
            entries
        }
    }

    func purge(matching filter: Logger.Filter?) {}
}

extension Logger.Subsystem {
    static let sub1: Logger.Subsystem = "package.diagnostics"
    static let sub2: Logger.Subsystem = "app.iOS"
}

extension Logger.Entry {
    static let one = Logger.Entry(
        date: Calendar.current.date(byAdding: .minute, value: -2, to: Date())!,
        subsystem: .sub1,
        level: .debug,
        message: "Requesting Permissions",
        metadata: nil,
        source: "",
        file: "PermissionManager.swift",
        function: "requestPermissions()",
        line: 169
    )

    static let two = Logger.Entry(
        date: Calendar.current.date(byAdding: .minute, value: -3, to: Date())!,
        subsystem: .sub2,
        level: .warning,
        message: "Authentication Expired",
        metadata: nil,
        source: "",
        file: "AuthenticationManager.swift",
        function: "checkAuthenticationState()",
        line: 65
    )

    static let three = Logger.Entry(
        date: Calendar.current.date(byAdding: .minute, value: -4, to: Date())!,
        subsystem: .sub2,
        level: .info,
        message: "Bundle",
        metadata: [
            "bundleName": "MyApp",
            "bundleIdentifier": "tld.domain.app",
            "appVersion": "1.0.0",
            "buildNumber": "100",
            "operatingEnvironment": "Release (TestFlight)",
        ],
        source: "",
        file: "AppDelegate.swift",
        function: "application(_:didFinishLaunchingWithOptions:)",
        line: 24
    )

    static let four = Logger.Entry(
        date: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!,
        subsystem: .sub1,
        level: .error,
        message: "404",
        metadata: nil,
        source: "",
        file: "NetworkManager.swift",
        function: "get(request:)",
        line: 402
    )
}
