import Foundation
import Logging

extension Logger.Level {
    public var gem: String {
        switch self {
        case .trace: return "🔦"
        case .debug: return "🦠"
        case .info: return "🔎"
        case .notice: return "📎"
        case .warning: return "⚠️"
        case .error: return "🚫"
        case .critical: return "☢️"
        }
    }
    
    public var fixedWidthDescription: String {
        let max = Logger.Level.allCases.map { $0.rawValue.count }.max() ?? rawValue.count
        return rawValue.uppercased().padding(toLength: max, withPad: " ", startingAt: 0)
    }
}
