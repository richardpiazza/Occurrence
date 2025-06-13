import Foundation
import Logging

public extension Logger {
    enum Filter: Hashable, Sendable {
        /// An exact match based on the provided `Logger.Subsystem`,
        case subsystem(Subsystem)
        /// An exact match based on the provided `Logger.Level`.
        case level(Level)
        /// An approximate (_contains_) match based on the provided Message value.
        case message(String)
        /// An approximate (_contains_) match based on the provided Source name.
        case source(String)
        /// An approximate (_contains_) match based on the provided File name.
        case file(String)
        /// An approximate (_contains_) match based on the provided Function name.
        case function(String)
        /// A ranged match between the provided dates.
        case period(start: Date, end: Date)
        case and([Filter])
        case or([Filter])
        case not([Filter])
    }
}
