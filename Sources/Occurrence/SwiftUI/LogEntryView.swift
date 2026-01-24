#if canImport(SwiftUI)
import Logging
import SwiftUI

struct LogEntryView: View {

    var entry: Logger.Entry

    var backgroundColor: Color {
        switch entry.level {
        case .trace: .gray
        case .debug: .blue
        case .info: .yellow
        case .notice: .brown
        case .warning: .orange
        case .error: .pink
        case .critical: .red
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.level.fancyDescription)

                Text(Logger.Entry.gmtDateFormatter.string(from: entry.date))
            }
            .font(.system(size: 10, weight: .semibold, design: .monospaced))

            Divider()

            VStack(alignment: .leading) {
                Text(entry.subsystem.description)

                Text("\(entry.fileName) \(entry.line)")

                Text(entry.function)
            }
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .font(.system(size: 10, weight: .thin, design: .monospaced))

            Divider()

            Text(entry.message.description)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
        }
        .padding(8.0)
        .overlay {
            RoundedRectangle(cornerRadius: 8.0)
                .stroke(lineWidth: 1.5)
                .foregroundStyle(backgroundColor)
        }
    }
}
#endif
