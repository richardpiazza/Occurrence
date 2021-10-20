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
}
