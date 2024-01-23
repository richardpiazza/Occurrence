extension DecodingError: CustomMetadataError {
    public static var errorDomain: String { "swift.decoding-error" }
    
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
            return "Decoding (Type Mismatch) - Type: \(String(describing: any)), Context: \(context.debugDescription) \(context.codingPath)"
        case .valueNotFound(let any, let context):
            return "Decoding (Value Not Found) - Type: \(String(describing: any)), Context: \(context.debugDescription) \(context.codingPath)"
        case .keyNotFound(let codingKey, let context):
            return "Decoding (Key Not Found) - Key: \(codingKey), Context: \(context.debugDescription) \(context.codingPath)"
        case .dataCorrupted(let context):
            return "Decoding (Data Corrupted) - Context: \(context.debugDescription) \(context.codingPath)"
        @unknown default:
            return "Decoding (Unknown) - \(localizedDescription)"
        }
    }
}
