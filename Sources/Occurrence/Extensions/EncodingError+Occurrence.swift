extension EncodingError: CustomMetadataError {
    public static var errorDomain: String { "SwiftEncodingErrorDomain" }
    
    public var errorCode: Int {
        switch self {
        case .invalidValue: return 0
        @unknown default: return -1
        }
    }
    
    public var description: String {
        switch self {
        case .invalidValue(let value, let context):
            let path = context.codingPath.map { $0.stringValue }
            return "Encoding (Invalid Value) - Value: \(value), Context: \(context.debugDescription) \(path)"
        @unknown default:
            return "Encoding (Unknown) - \(localizedDescription)"
        }
    }
}
