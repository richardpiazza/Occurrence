import Foundation
import Logging

extension Logger.Level {
    /// A unique visual indicator for each `Level`.
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
    
    /// A padded representation of the `Level`.
    public var fixedWidthDescription: String {
        let max = Logger.Level.allCases.map { $0.rawValue.count }.max() ?? rawValue.count
        return rawValue.padding(toLength: max, withPad: " ", startingAt: 0)
    }
}

extension Logger.Level: CustomStringConvertible {
    public var description: String {
        var fixedWidthGem = gem
        if gem.unicodeScalars.count > 1 {
            fixedWidthGem.append(" ")
        }
        
        return "\(fixedWidthGem) \(fixedWidthDescription.uppercased())"
    }
}
