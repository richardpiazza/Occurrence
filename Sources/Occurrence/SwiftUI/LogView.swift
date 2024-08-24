import Logging
#if canImport(SwiftUI)
import SwiftUI
import Combine

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
    
    public class ViewModel: ObservableObject {
        public typealias ExportAction = ([Logger.Entry]) -> Void
        
        @Published var subsystems: [Logger.Subsystem?] = [nil]
        @Published var levels: [Logger.Level?] = [nil]
        @Published var selectedSubsystem: Logger.Subsystem? {
            didSet {
                reload()
            }
        }
        @Published var selectedLevel: Logger.Level? {
            didSet {
                reload()
            }
        }
        @Published var live: Bool = true {
            didSet {
                reload()
            }
        }
        @Published var entries: [Logger.Entry] = []
        @Published var allowManagement: Bool = false
        
        var subsystemDescription: String { selectedSubsystem?.description ?? "All" }
        
        private let storage: LogStorage
        private let streamer: LogStreamer
        public var exportAction: ExportAction?
        private var liveSubscription: AnyCancellable?
        
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
        
        /// Initialize `LogView` settings
        ///
        /// - parameters:
        ///   - storage:
        ///   - streamer:
        ///   - allowManagement: Whether management and filtering tools are available
        ///   - exportAction:
        public init(
            storage: LogStorage = OccurrenceLogStorage(),
            streamer: LogStreamer = OccurrenceLogStreamer(),
            allowManagement: Bool = true,
            exportAction: ExportAction? = nil
        ) {
            self.storage = storage
            self.streamer = streamer
            self.allowManagement = allowManagement
            self.exportAction = exportAction
            subsystems.append(contentsOf: storage.subsystems())
            levels.append(contentsOf: Logger.Level.allCases)
            reload()
        }
        
        deinit {
            liveSubscription?.cancel()
            liveSubscription = nil
        }
        
        func reload() {
            liveSubscription?.cancel()
            liveSubscription = nil
            
            let filter = self.filter
            
            entries = storage.entries(filter, limit: 50)
            
            guard live else {
                return
            }
            
            liveSubscription = streamer.publisher
                .filter({ $0.matchesFilter(filter) })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] entry in
                    self?.entries.insert(entry, at: 0)
                })
        }
        
        func manage(_ option: ManageOption) {
            switch option {
            case .removeOld:
                let lastWeek = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
                let filter: Logger.Filter = .period(start: .distantPast, end: lastWeek)
                storage.purge(matching: filter)
                entries.removeAll(where: { $0.matchesFilter(filter) })
            case .removeAll:
                storage.purge(matching: nil)
                entries.removeAll()
            }
        }
        
        func export(_ option: ExportOption) {
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
            
            let entries = storage.entries(filter, ascending: true)
            action(entries)
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    
    public init(viewModel: ViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 4.0) {
            #if os(iOS) || os(macOS)
            if viewModel.allowManagement {
                entryManagementView
                    .padding()
                
                Divider()
                
                filterView
                    .padding()
                
                Divider()
            }
            #endif
            
            ScrollView {
                ForEach(viewModel.entries, id: \.date) { entry in
                    LogEntryView(entry: entry)
                        .padding([.leading, .trailing])
                }
            }
        }
        .navigationTitle("System Log")
    }
    
    #if os(iOS) || os(macOS)
    private var entryManagementView: some View {
        HStack {
            Menu {
                ForEach(ManageOption.allCases, id: \.self) { option in
                    Button {
                        viewModel.manage(option)
                    } label: {
                        Text(option.rawValue)
                    }
                }
            } label: {
                Text(Image(systemName: "trash")) + Text(" Manage")
            }
            
            Spacer()
            
            Menu {
                ForEach(ExportOption.allCases, id: \.self) { option in
                    Button {
                        viewModel.export(option)
                    } label: {
                        Text(option.rawValue)
                    }
                }
            } label: {
                Text(Image(systemName: "square.and.arrow.up")) + Text(" Export")
            }
        }
    }
    
    private var filterView: some View {
        VStack {
            HStack {
                Text("Subsystem")
                    .font(.caption)
                    .bold()
                if viewModel.subsystems.isEmpty {
                    Text(viewModel.subsystemDescription)
                } else {
                    Picker(viewModel.subsystemDescription, selection: $viewModel.selectedSubsystem) {
                        ForEach(viewModel.subsystems, id: \.self) { subsystem in
                            Text(subsystem?.rawValue ?? "All")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                }
                
                Spacer()
                
                Text("🚰")
                
                Toggle("", isOn: $viewModel.live)
                    .labelsHidden()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Level")
                        .font(.caption)
                        .bold()
                    Text(viewModel.selectedLevel?.rawValue ?? "All")
                        .font(.caption)
                }
                Picker("Level", selection: $viewModel.selectedLevel) {
                    ForEach(viewModel.levels, id: \.self) { level in
                        Text(level?.gem ?? "All")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    #endif
    
    struct LogEntryView: View {
        
        let entry: Logger.Entry
        @State private var backgroundColor: Color = .clear
        
        private func color(forLevel level: Logger.Level) -> Color {
            switch level {
            case .trace: return .white
            case .debug: return .gray
            case .info: return .blue
            case .notice: return .yellow
            case .warning: return .orange
            case .error: return .pink
            case .critical: return .red
            }
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.level.description)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                        Text(Logger.Entry.gmtDateFormatter.string(from: entry.date))
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                    }
                    
                    Text(entry.subsystem.description)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("\(entry.fileName) \(entry.line)")
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .font(.system(size: 10, weight: .thin, design: .monospaced))
                    Text(entry.function)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .font(.system(size: 10, weight: .thin, design: .monospaced))
                }
                
                Divider()
                
                Text(entry.message.description)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
            }
            .padding()
            .background(backgroundColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16.0))
            .onAppear() {
                withAnimation(.easeIn(duration: 0.75)) {
                    backgroundColor = color(forLevel: entry.level)
                }
            }
        }
    }
}

public struct SwiftUIView_Previews: PreviewProvider {
    public static var previews: some View {
        NavigationView {
            LogView(viewModel: .init(storage: PreviewLogStorage(), streamer: OccurrenceLogStreamer()))
        }
    }
}

private extension Logger.Subsystem {
    static let sub1: Logger.Subsystem = "package.diagnostics"
    static let sub2: Logger.Subsystem = "app.iOS"
}

private struct PreviewLogStorage: LogStorage {
    
    private let entries: [Logger.Entry] = [
        .init(
            date: Calendar.current.date(byAdding: .minute, value: -2, to: Date())!,
            subsystem: .sub1,
            level: .debug,
            message: "Requesting Permissions",
            metadata: nil,
            source: "",
            file: "PermissionManager.swift",
            function: "requestPermissions()",
            line: 169
        ),
        .init(
            date: Calendar.current.date(byAdding: .minute, value: -3, to: Date())!,
            subsystem: .sub2,
            level: .warning,
            message: "Authentication Expired",
            metadata: nil,
            source: "",
            file: "AuthenticationManager.swift",
            function: "checkAuthenticationState()",
            line: 65
        ),
        .init(
            date: Calendar.current.date(byAdding: .minute, value: -4, to: Date())!,
            subsystem: .sub2,
            level: .info,
            message: "Bundle",
            metadata: [
              "bundleName": "MyApp",
              "bundleIdentifier": "tld.domain.app",
              "appVersion": "1.0.0",
              "buildNumber": "100",
              "operatingEnvironment": "Release (TestFlight)"
            ],
            source: "",
            file: "AppDelegate.swift",
            function: "application(_:didFinishLaunchingWithOptions:)",
            line: 24
        ),
        .init(
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
    ]
    
    func log(_ entry: Logger.Entry) {
        
    }
    
    func subsystems() -> [Logger.Subsystem] {
        return [.sub1, .sub2]
    }
    
    func entries(matching filter: Logger.Filter?, ascending: Bool, limit: UInt) -> [Logger.Entry] {
        if let filter = filter {
            return entries.filter({ $0.matchesFilter(filter) })
        } else {
            return entries
        }
    }
    
    func purge(matching filter: Logger.Filter?) {
    }
}
#endif
