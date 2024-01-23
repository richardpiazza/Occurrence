extension DecodingError: CustomMetadataError {
    public static var errorDomain: String { "SwiftDecodingErrorDomain" }
    
    public var errorCode: Int {
        switch self {
        case .typeMismatch: return 0
        case .valueNotFound: return 1
        case .keyNotFound: return 2
        case .dataCorrupted: return 3
        @unknown default: return -1
        }
    }
    
    public var description: String {
        switch self {
        case .typeMismatch(let any, let context):
            let path = context.codingPath.map { $0.stringValue }
            return "Decoding (Type Mismatch) - Type: \(String(describing: any)), Context: \(context.debugDescription) \(path)"
        case .valueNotFound(let any, let context):
            let path = context.codingPath.map { $0.stringValue }
            return "Decoding (Value Not Found) - Type: \(String(describing: any)), Context: \(context.debugDescription) \(path)"
        case .keyNotFound(let codingKey, let context):
            let path = context.codingPath.map { $0.stringValue }
            return "Decoding (Key Not Found) - Key: \(codingKey), Context: \(context.debugDescription) \(path)"
        case .dataCorrupted(let context):
            let path = context.codingPath.map { $0.stringValue }
            return "Decoding (Data Corrupted) - Context: \(context.debugDescription) \(path)"
        @unknown default:
            return "Decoding (Unknown) - \(localizedDescription)"
        }
    }
}
