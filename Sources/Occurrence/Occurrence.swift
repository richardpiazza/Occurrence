import Logging

public struct Occurrence: LogHandler {
    
    public let label: String
    public var metadata: Logger.Metadata = .init()
    public var logLevel: Logger.Level = .trace
    
    public init(label: String) {
        self.label = label
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        print("""
        {
          "level": "\(level)",
          "message": "\(message)",
          "source": "\(source)",
          "file": "\(file)",
          "function": "\(function)",
          "line": \(line),
        }
        """)
    }
}
