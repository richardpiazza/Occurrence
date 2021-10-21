import Foundation
import Logging

public extension Logger {
    @inlinable
    func error(
        _ message: @autoclosure () -> Logger.Message,
        error: @autoclosure () -> Error,
        source: @autoclosure () -> String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let _error = error()
        
        var meta: Logger.Metadata
        
        if let provider = _error as? MetadataProvider {
            meta = provider.metadata
        } else if let localized = _error as? LocalizedError {
            meta = .init()
            meta["localizedDescription"] = .string(localized.localizedDescription)
            
            if let errorDescription = localized.errorDescription {
                meta["errorDescription"] = .string(errorDescription)
            }
            if let failureReason = localized.failureReason {
                meta["failureReason"] = .string(failureReason)
            }
            if let recoverySuggestion = localized.recoverySuggestion {
                meta["recoverySuggestion"] = .string(recoverySuggestion)
            }
            if let helpAnchor = localized.helpAnchor {
                meta["helpAnchor"] = .string(helpAnchor)
            }
        } else {
            meta = .init()
            meta["localizedDescription"] = .string(_error.localizedDescription)
        }
        
        self.log(level: .error, message(), metadata: meta, source: source(), file: file, function: function, line: line)
    }
}

public protocol MetadataProvider {
    var metadata: Logger.Metadata { get }
}

extension DecodingError: MetadataProvider {
    public var metadata: Logger.Metadata {
        return ["":""]
    }
}

extension EncodingError: MetadataProvider {
    public var metadata: Logger.Metadata {
        return ["":""]
    }
}
