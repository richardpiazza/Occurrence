import Foundation
import Logging

public extension Logger.Level {
    /// A unique visual indicator for each `Level`.
    var gem: String {
        switch self {
        case .trace: "🚰"
        case .debug: "🦠"
        case .info: "🔎"
        case .notice: "💡"
        case .warning: "🔮"
        case .error: "🚫"
        case .critical: "💣"
        }
    }

    /// A padded representation of the `Level`.
    var fixedWidthDescription: String {
        let max = Logger.Level.allCases.map(\.rawValue.count).max() ?? rawValue.count
        return rawValue.padding(toLength: max, withPad: " ", startingAt: 0)
    }
}

extension Logger.Level: @retroactive CustomStringConvertible {
    public var description: String {
        "\(gem) \(fixedWidthDescription.uppercased())"
    }
}
