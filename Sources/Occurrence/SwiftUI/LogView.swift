#if canImport(SwiftUI)
import Logging
import SwiftUI

/// View which presents and manages log entries.
///
/// A `LogView` utilizes the SwiftUI `EnvironmentValues`:
/// ```swift
/// @Environment(\.logStreamer)
/// @Environment(\.logProvider)
/// ```
@available(macOS 13.0, macCatalyst 16.0, iOS 16.0, tvOS 17.0, watchOS 9.0, visionOS 1.0, *)
public struct LogView: View {

    enum ManageOption: String, CaseIterable {
        case removeOld = "Remove Old (> 3 Days)"
        case removeAll = "Remove All (Reset)"
    }

    enum ExportOption: String, CaseIterable {
        case recent = "Recent (1 Hour)"
        case today = "Today (Since Midnight)"
        case extended = "Extended (3 Days)"
    }

    @State var allowManagement: Bool
    var exportAction: (([Logger.Entry]) -> Void)?

    @State private var subsystems: [Logger.Subsystem?] = [nil]
    @State private var levels: [Logger.Level?] = [nil]
    @State private var selectedSubsystem: Logger.Subsystem?
    @State private var selectedLevel: Logger.Level?
    @State private var live: Bool = true
    @State private var entries: [Logger.Entry] = []

    @Environment(\.logStreamer) private var logStreamer
    @Environment(\.logProvider) private var logProvider

    private var filter: Logger.Filter {
        var filters: [Logger.Filter] = []
        if let subsystem = selectedSubsystem {
            filters.append(.subsystem(subsystem))
        }
        if let level = selectedLevel {
            filters.append(.level(level))
        }

        return .and(filters)
    }

    private var subsystemDescription: String {
        selectedSubsystem?.description ?? "All"
    }

    private var levelDescription: String {
        selectedLevel?.fancyDescription ?? "All"
    }

    private var liveDescription: String {
        live ? "Pause" : "Resume"
    }

    /// Initialize a `LogView`
    ///
    /// - parameters:
    ///   - allowManagement: Indicates if management features are available.
    ///   - exportAction: Handler to be called when log entries are exported.
    public init(
        allowManagement: Bool = true,
        exportAction: (([Logger.Entry]) -> Void)? = nil,
    ) {
        _allowManagement = State(wrappedValue: allowManagement)
        self.exportAction = exportAction
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(entries, id: \.date) { entry in
                    LogEntryView(entry: entry)
                }
            }
            .padding(.horizontal)
            .navigationTitle("System Log")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if allowManagement {
                        #if !os(watchOS)
                        Menu {
                            Text("Subsystem")

                            Picker(subsystemDescription, selection: $selectedSubsystem) {
                                ForEach(subsystems, id: \.self) { subsystem in
                                    Text(subsystem?.rawValue ?? "All")
                                }
                            }
                            .pickerStyle(.menu)

                            Divider()

                            Text("Level")

                            Picker(levelDescription, selection: $selectedLevel) {
                                ForEach(levels, id: \.self) { level in
                                    Text(level?.fancyDescription ?? "All")
                                }
                            }
                            .pickerStyle(.menu)
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease")
                        }

                        Menu {
                            ForEach(ExportOption.allCases, id: \.self) { option in
                                Button {
                                    export(option)
                                } label: {
                                    Text(option.rawValue)
                                }
                            }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Menu {
                            ForEach(ManageOption.allCases, id: \.self) { option in
                                Button {
                                    manage(option)
                                } label: {
                                    Text(option.rawValue)
                                }
                            }
                        } label: {
                            Label("Trash", systemImage: "trash")
                        }
                        #endif
                    }

                    Toggle(isOn: $live) {
                        Label(liveDescription, systemImage: live ? "pause" : "play")
                    }
                }
            }
        }
        .task {
            subsystems.append(contentsOf: logProvider.subsystems())
            levels.append(contentsOf: Logger.Level.allCases)
        }
        .task(id: filter) {
            entries = logProvider.entries(filter, limit: 50)
        }
        .task(id: live) {
            if live {
                for await value in logStreamer.stream {
                    if value.matchesFilter(filter) {
                        entries.append(value)
                    }
                }
            }
        }
    }

    private func manage(_ option: ManageOption) {
        switch option {
        case .removeOld:
            let lastWeek = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            let filter: Logger.Filter = .period(start: .distantPast, end: lastWeek)
            logProvider.purge(matching: filter)
            entries.removeAll(where: { $0.matchesFilter(filter) })
        case .removeAll:
            logProvider.purge(matching: nil)
            entries.removeAll()
        }
    }

    private func export(_ option: ExportOption) {
        guard let action = exportAction else {
            return
        }

        let filter: Logger.Filter

        switch option {
        case .recent:
            let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
            filter = .period(start: hourAgo, end: Date())
        case .today:
            let midnight = Calendar.current.startOfDay(for: Date())
            filter = .period(start: midnight, end: Date())
        case .extended:
            let threeDays = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            filter = .period(start: threeDays, end: Date())
        }

        let entries = logProvider.entries(filter, ascending: true)
        action(entries)
    }
}

@available(macOS 13.0, macCatalyst 16.0, iOS 16.0, tvOS 17.0, watchOS 9.0, visionOS 1.0, *)
#Preview {
    LogView()
        .environment(\.logProvider, PreviewLogProvider())
        .environment(\.logStreamer, OccurrenceLogStreamer())
    #if os(macOS)
        .frame(width: 500)
    #endif
}
#endif
