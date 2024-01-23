extension EncodingError: CustomMetadataError {
    public static var errorDomain: String { "swift.encoding-error" }
    
    public var errorCode: Int {
        switch self {
        case .invalidValue: return 0
        @unknown default: return -1
        }
    }
    
    public var description: String {
        switch self {
        case .invalidValue(let value, let context):
            return "Encoding (Invalid Value) - Value: \(value), Context: \(context.debugDescription) \(context.codingPath)"
        @unknown default:
            return "Encoding (Unknown) - \(localizedDescription)"
        }
    }
}
